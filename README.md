# smart_warehouse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## E2E tests (Patrol)

Los tests end-to-end viven en `integration_test/` y corren con [Patrol](https://patrol.leancode.co) contra el **backend local** (deben existir el usuario `admin@smartwarehouse.local` / `changeme` y productos seedeados).

### Prerrequisitos

1. `dart pub global activate patrol_cli` (una sola vez), y `patrol doctor` para verificar.
2. Backend corriendo en `localhost:8080` (los tests usan `10.0.2.2:8080` en Android automáticamente).
3. Un emulador Android o simulador iOS booteado.
4. Solo iOS, una vez: abrir `ios/Runner.xcworkspace` en Xcode y crear un target de tipo **UI Testing Bundle** llamado `RunnerUITests` (target a testear: Runner), borrar los archivos generados y agregar al target el archivo existente `ios/RunnerUITests/RunnerUITests.m`. Luego `cd ios && pod install`. El bloque de Podfile ya está agregado.

### Correr

```sh
make e2e                # dispositivo por defecto
make e2e-android        # emulador Android
make e2e-ios            # simulador iOS
make e2e API_BASE_URL=http://192.168.0.10:8080 E2E_EMAIL=otro@mail.com E2E_PASSWORD=secreto
```

O un archivo puntual: `patrol test -t integration_test/cart_checkout_test.dart`.

### Qué cubren

- `login_test.dart` — credenciales inválidas (banner de error) y válidas (llega al catálogo).
- `catalog_test.dart` — listado, búsqueda por SKU, y **consistencia de precio catálogo ↔ detalle**.
- `cart_checkout_test.dart` — agregar al carrito, **consistencia de precio/moneda en todo el flujo** (card → detalle → botón agregar (unit × qty) → línea del carrito → total → diálogo de confirmación), checkout completo hasta "¡Pedido creado!", y quitar items.
- `orders_test.dart` — lista de órdenes y detalle.
- `profile_test.dart` — perfil y cerrar sesión.

Los finders usan las keys centralizadas en `packages/design_system/lib/testing/e2e_keys.dart` (`E2eKeys`). Si agregás pantallas nuevas, agregá ahí las keys.

Todos los precios visibles se parsean con el formato único de `Money.formatted` (`$1.234,56`); cualquier moneda o formato distinto entre catálogo, carrito y checkout hace fallar el test (guardia de regresión del bug de moneda en el carrito).
