# Contrato de datos para los tests e2e (E8.3.7, #151)

Qué garantiza el backend local a la suite Patrol (`integration_test/`) y qué
reglas siguen los tests que crean o modifican datos.

## Qué garantiza el seed del backend

El stack local (`make up-dev` en `wh-backend`) seedea:

| Garantía | Valor | Quién depende |
|---|---|---|
| Usuario admin | `admin@smartwarehouse.local` / `changeme` (SUPERADMIN) | todos los tests (`E2eConfig`) |
| Productos | ≥ 2 productos activos, con precio en **ARS** y stock disponible > 0 | catálogo, carrito, checkout, mixed-currency |
| Moneda homogénea | todo el seed en una sola moneda (ARS) | contrato Money (los tests de precio asumen formato `$1.234,56`) |
| Tamaño de página | el catálogo pide `size=20`; el seed (16 productos) entra en una página | paginación (crea sus propios extras) |

Si el seed cambia (menos de 2 productos, otra moneda, productos sin stock),
estos tests fallan por setup, no por regresión: revisar esta tabla primero.

## Reglas para tests que mutan datos

1. **Prefijo `E2E-`** en el SKU de todo producto creado por un test
   (`E2E-PAG-01`, `E2E-TMP-...`). Nada con ese prefijo es del seed y puede
   borrarse siempre.
2. **Teardown en `finally`**: lo creado se borra y lo modificado se restaura
   aunque el test falle (`catalog_pagination_test`, `mixed_currency_test`).
3. **Órdenes**: el checkout crea órdenes reales; al final del test se cancelan
   todas las `pending` vía `E2eApi.cancelPendingOrders` para no ensuciar la
   lista de órdenes ni "gastado este mes" de corridas futuras.
4. **Idempotencia**: los setups toleran sobras de corridas anteriores (un SKU
   `E2E-` duplicado no corta el setup).

Los helpers HTTP viven en `integration_test/common/api_helpers.dart` y hablan
con el mismo host que la app (en Android emulador, `10.0.2.2:8080`).

## Reset completo

Para volver a un estado limpio garantizado:

```sh
cd ../wh-backend
docker compose --profile dev down -v   # borra el volumen de Mongo
make up-dev                            # re-crea y re-seedea
```

No hay endpoint de reset en la API (decisión: el reset es infraestructura, no
dominio). Si algún día existe, reemplaza al `down -v`.
