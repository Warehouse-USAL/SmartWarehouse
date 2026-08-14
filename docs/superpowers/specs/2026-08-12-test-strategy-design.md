# Estrategia de tests unitarios y gate de cobertura — Design

**Fecha**: 2026-08-12
**Issue**: E8.2 (se reescribe como epic — ver §9)
**Estado**: aprobado, pendiente de plan de implementación

---

## 1. Contexto

El monorepo tiene 12 packages más el app shell (~14.500 LOC de código no generado).
Solo 4 packages tienen tests. La cobertura nunca se midió y CI no la controla.

### Baseline medido (2026-08-12)

| Package | Cobertura | Líneas | Archivos fuente | LOC |
|---|---|---|---|---|
| `login` | 60.6% | 20/33 | 24 | 887 |
| `catalog` | 31.8% | 287/902 | 37 | 2.335 |
| `order_tracking` | 25.8% | 194/752 | 30 | 2.259 |
| `orders` | 23.8% | 64/269 | 20 | 1.048 |
| `core` | 0% | — | 13 | 195 |
| `commons` | 0% | — | 30 | 1.096 |
| `design_system` | 0% | — | 41 | 3.190 |
| `auth` | 0% | — | 10 | 473 |
| `cart` | 0% | — | 12 | 737 |
| `profile` | 0% | — | 20 | 1.721 |
| `bottom_navigation_bar` | 0% | — | 5 | 165 |
| `token_repository` | 0% | — | 4 | 65 |
| app shell (`lib/`) | 0% | — | 7 | 377 |

> **Estos números son indicativos, no los floors iniciales.** Se midieron con el lcov
> crudo, que hoy incluye `*.g.dart` y solo contiene los archivos que los tests importan.
> Los floors reales los siembra el tooling de Fase 0 corriéndose a sí mismo (§6.4).
> Se espera que bajen respecto de la tabla.

### Defectos encontrados en el setup actual

1. **`melos.yaml` deja pasar packages sin tests en silencio.** El script es
   `if [ -d "test" ]; then flutter test --no-pub; fi`. Los 8 packages sin carpeta
   `test/` reportan éxito en CI sin ejecutar nada.
2. **lcov incluye código generado.** `product_dto.g.dart`, `pagination_dto.g.dart`, etc.
   aparecen como entradas `SF:`. `analysis_options.yaml` excluye el código generado del
   *analyzer*, pero lcov no sabe nada de eso.
3. **Un package sin tests no emite `lcov.info`.** Un script de merge ingenuo lo saltea en
   lugar de puntuarlo 0% — la misma clase de bug que (1), una capa más abajo.
4. **`ARCHITECTURE.md` §18 contradice la decisión de este spec.** Hoy prohíbe mockito y
   manda fakes a mano; adoptamos `mocktail` + `bloc_test`.

---

## 2. Objetivos

- Gate de cobertura por package en CI, con umbrales escalonados por capa y **ratchet**
  (los floors solo suben).
- Convención única de testing, documentada, aplicada a los 12 packages.
- Frontera explícita con el trabajo de Patrol (E2E) que otro dev está integrando.
- Trazabilidad en el board **wh-mobile**: un issue por package bajo un epic.

## 3. No objetivos

- **No** buscamos 100% de cobertura. Fuerza tests sobre código generado, getters triviales
  y glue de UI, y premia inflar el número. E8.2 se reescribe en consecuencia (§9).
- **No** testeamos pages con unit/widget tests — esa capa es de Patrol (§10).
- **No** integramos servicios externos de cobertura (Codecov y similares) en este alcance.

---

## 4. Convenciones de testing

### 4.1 Qué se testea por capa

| Capa | ¿Se testea? | Cómo |
|---|---|---|
| Entities Freezed | **No** | `==`/`copyWith` generados son responsabilidad de Freezed. Solo se testean métodos y getters escritos a mano. |
| Mappers (DTO→entity) | Sí | Table-driven contra JSON real del backend. Ya es la convención §18. |
| Repos mock / in-memory | Sí | Paginación, filtros, página vacía y fuera de rango. |
| Repos remote | Sí | Parsing del contrato + mapeo de errores HTTP, con `HttpHelper` mockeado. |
| Cubits | Sí | `blocTest` por acción pública: éxito, fallo, secuencia de loading, descarte de respuestas stale, acumulación de paginación. |
| Use cases (`core`) | Sí | Llamada directa con colaboradores mockeados. |
| Utils / helpers | Sí | Unit tests planos. |
| Widgets | Selectivo | Solo componentes **con lógica**: estado, callbacks, render condicional. Los de layout puro quedan fuera. |
| Pages | **No** | Capa de Patrol. Testearlas dos veces es desperdicio. |

### 4.2 Tooling

`mocktail` + `bloc_test` como estándar, en `dev_dependencies` de todos los packages.

- `mocktail`: sin codegen, null-safe, `when()`/`verify()`.
- `bloc_test`: `build`/`act`/`expect`/`verify` declarativo, maneja el ciclo de vida del
  stream. Reemplaza el patrón actual de `cubit.stream.listen` + `Future.delayed(Duration.zero)`,
  que es frágil por timing.

Se siguen usando fakes a mano **solo** donde un fake con estado es genuinamente más claro
que un mock (repos in-memory que simulan un store).

### 4.3 `packages/test_support`

Package nuevo, solo para desarrollo (no se publica, no entra en el bundle de la app):

- **Builders de entities**: `aProduct()`, `anOrder()`, `aCartItem()`, con defaults
  razonables y overrides por parámetro nombrado.
- **Carga de fixtures JSON**: helper para leer los golden files del contrato del backend.
- **Mocks compartidos** de `mocktail` y sus `registerFallbackValue`.

Motivo: la duplicación ya existe. `order_tracking` reimplementa a mano un `_FakeCatalog`
que los tests de `catalog` ya definen, con los tres métodos no usados devolviendo
`Left(CatalogFailure('not used'))`.

`test_support` queda excluido del gate de cobertura (es código de test).

---

## 5. Umbrales

| Package | Target | Justificación |
|---|---|---|
| `core` | 85% | Use cases y entities puras, sin dependencias de plataforma. |
| `commons` | 85% | Sobre lo que queda tras las exclusiones de §5.1. |
| `token_repository` | 85% | 65 LOC, lógica pura. |
| `auth` | 80% | Capa de feature. |
| `cart` | 80% | Capa de feature. |
| `orders` | 80% | Capa de feature. |
| `order_tracking` | 80% | Capa de feature. |
| `login` | 80% | Capa de feature. |
| `catalog` | 80% | Capa de feature. |
| `profile` | 80% | Capa de feature. |
| `bottom_navigation_bar` | 60% | Casi todo UI. |
| `design_system` | 40% | 41 archivos de widgets; solo los que tienen lógica. |
| app shell (`lib/`) | excluido | Composition root y bootstrap; se cubre vía E2E. |
| `test_support` | excluido | Es código de test. |

### 5.1 Exclusiones

**Globales** (todos los packages):

```
**/*.g.dart
**/*.freezed.dart
**/presentation/pages/**
```

**Pages** — no se testean con unit/widget tests a propósito (§4.1): esa capa la
cubre Patrol (#131). Dejarlas en el denominador de cobertura hacía que el target
de §5 fuera inalcanzable por aritmética en algunos packages — en `cart` la page
sola (`cart_page.dart`) es 133 de las 290 líneas instrumentables del package, un
techo teórico de 54% aunque el resto del código estuviera 100% cubierto. Por eso
`**/presentation/pages/**` es una exclusión global, no por-package: no es un caso
particular de `cart`, es la misma inconsistencia entre §4.1 y §5 en cualquier
feature con una page grande.

**Consecuencia: una page no puede contener lógica de negocio.** Validaciones,
mappers y decisiones de dominio van al cubit o a un mapper. Si viven en la page
quedan fuera del gate **y** fuera de Patrol por igual, sin que nadie lo note.
Hoy `cart_page.dart` viola esto: tiene el guard de sobre-pedido (`quantity >
available`) y un mapper Cart→OrderItem. Ver el issue de seguimiento (#173).

Al aplicar esta exclusión, la cobertura medida de cinco packages subió sin que
se escribiera ningún test — solo cambió el denominador: `catalog` 29.5→43.6,
`order_tracking` 24.5→33.1, `orders` 20.0→24.2, `login` 9.4→14.1, `profile`
1.0→1.3. De 703 líneas sacadas del denominador, exactamente **una** estaba
cubierta. Los floors se re-ratchetearon en consecuencia.

**Adaptadores finos de plataforma en `commons`** — delegación pura a un plugin. Testearlos
significa afirmar "¿se llamó a Hive?", lo cual es tautológico y se rompe cada vez que cambia
la API del plugin, sin detectar defectos reales:

| Archivo | Motivo |
|---|---|
| `helpers/persistence_helper/hive_persistence_helper.dart` | delega en Hive |
| `helpers/persistence_helper/shared_preferences_persistence_helper.dart` | delega en SharedPreferences |
| `helpers/image_picker_helper/image_picker_helper_implementation.dart` | delega en image_picker |
| `helpers/permissions/permissions_handler_package/permissions_handler_helper.dart` | delega en permission_handler |
| `helpers/navigation_helper/beamer_navigation_helper.dart` | delega en Beamer |
| `helpers/http/dio_http_helper.dart` | delega en Dio |
| `helpers/build_data/package_info_build_data_helper.dart` | agregado durante la implementación (no estaba en este listado original); delega casi todo en `package_info_plus`, más un `??` y un `.toUpperCase()` triviales. No es load-bearing: `commons` mide 85.3% sin contarlo. |

Lo que **sí** se cubre en `commons`: `utils/date_time_utils.dart`,
`utils/image_url_resolver.dart`, `helpers/http/interceptors/*`,
`helpers/permissions/permissions_handler_package/data/mappers/permission_type_mapper.dart`,
`helpers/http/entities/*`, `helpers/injector/get_it_injector.dart`.

Toda exclusión vive en `coverage_thresholds.yaml` con un motivo en línea. Agregar una
exclusión es un cambio revisable en un PR, nunca algo invisible.

---

## 6. Tooling de cobertura

### 6.1 `coverage_thresholds.yaml` (raíz del repo)

Forma del archivo (ejemplo abreviado; Fase 0 lo genera completo para los 12 packages):

```yaml
defaults:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/presentation/pages/**"

packages:
  core:
    path: packages/core
    min: 85
  commons:
    path: packages/commons
    min: 85
    exclude:
      - "lib/helpers/persistence_helper/hive_persistence_helper.dart"  # delega en Hive
      # ...resto de §5.1
  catalog:
    path: packages/features/catalog
    min: 80
  # ...

ignore:
  - path: .            # app shell
    reason: "composition root, cubierto por E2E"
  - path: packages/test_support
    reason: "código de test"
```

### 6.2 `tool/check_coverage.dart`

Script en Dart, **no bash**. Motivos: no hay que instalar el binario `lcov` en el runner,
corre igual en local y en CI, y **tiene sus propios unit tests** — un gate de cobertura roto
en silencio es peor que no tener gate.

Responsabilidades:

1. Leer `coverage/lcov.info` de cada package.
2. Filtrar `*.g.dart`, `*.freezed.dart` y las exclusiones configuradas.
3. Calcular el porcentaje por package y compararlo con su floor.
4. **Tratar un `lcov.info` ausente como 0%, nunca como skip.**
5. Imprimir una tabla y salir con código distinto de cero si algún package está bajo su floor.
6. Flag `--update`: reescribe los floors a los valores reales, para que subir un umbral sea
   un diff deliberado y revisable.

### 6.3 `tool/gen_coverage_imports.dart`

`flutter test --coverage` solo instrumenta los archivos que los tests importan: un archivo
sin tests no aparece en el reporte y no baja el porcentaje. Para que el denominador sea
honesto, este script genera por package un `test/_coverage_imports_test.dart` que importa
todos los archivos de `lib/` (gitignoreado, regenerado en cada corrida de `test:coverage`).

### 6.4 Siembra de floors

Los floors iniciales **no** se copian de la tabla de §1. Fase 0 corre el tooling nuevo
(con exclusiones y con `gen_coverage_imports` activos) y siembra `coverage_thresholds.yaml`
con los valores reales medidos. Así CI queda en verde el día que Fase 0 mergea, y cada PR
posterior sube el floor de su propio package.

### 6.5 `melos.yaml`

- Corregir `test`: sacar el `if [ -d "test" ]` que deja pasar en silencio.
- Agregar `test:coverage`: genera los imports, corre `flutter test --coverage` por package.

### 6.6 `ci.yml`

Job `coverage` nuevo, en paralelo a `test`, que corre `melos run test:coverage` y después
`dart tool/check_coverage.dart`. Sube el lcov mergeado como artifact.

---

## 7. Secuenciación

### 7.1 El grafo real de dependencias

Medido el 2026-08-13, **no** es lo que sugiere el nombre de los packages:

```
core     → commons, auth, login, bottom_navigation_bar, catalog,
           cart, orders, order_tracking, token_repository
commons  → core          ← ciclo con core
design_system → commons, core
token_repository → commons, core
auth     → commons, core
```

`core` depende de casi todas las features y **hay un ciclo `core ↔ commons`**. No existe un
package hoja: un orden "bottom-up por dependencias" es imposible.

### 7.2 Orden real: por testabilidad y leverage

Se ordena por qué tan aislable es el *código* (no el package), y por qué fixtures desbloquea
para las fases siguientes:

| Fase | Alcance | Por qué acá |
|---|---|---|
| **0** | Infra + `test_support` | Nada se puede medir ni gatear sin esto. |
| **1a** | `commons`: utils, entities de http, interceptor, mapper de permisos | Funciones puras sin dependencias: son hoja a nivel código aunque el package no lo sea. |
| **1b** | `token_repository` | 65 LOC, lógica pura de decode de JWT. |
| **1c** | `core` | Los use cases son estáticos que resuelven del `Injector` global: testeables, pero **cada test necesita scaffolding del Injector**, que `test_support` provee en Fase 0. |
| **2** | 7 features | Reusan los fixtures de 1a–1c. |
| **3** | `bottom_navigation_bar`, `design_system` | Casi todo UI. |

### 7.3 Entregables por fase

| Fase | Entregable |
|---|---|
| **0** | `mocktail` + `bloc_test` en todos los packages; `packages/test_support`; `coverage_thresholds.yaml`; `tool/check_coverage.dart` (+ sus tests); `tool/gen_coverage_imports.dart`; fix de `melos.yaml`; job `coverage` en CI; reescritura de `ARCHITECTURE.md` §18 |
| **1** | `commons` → 85%, `token_repository` → 85%, `core` → 85% (en ese orden, §7.2) |
| **2** | `auth`, `cart`, `orders`, `order_tracking`, `login`, `catalog`, `profile` → 80% |
| **3** | `bottom_navigation_bar` → 60%, `design_system` → 40% |

Un PR por package. Fase 0 mergea sola y primero.

**Nomenclatura de branches** (la valida CI contra
`^(feature|fix|enhancement|refactor|hotfix|beta|backport|dependabot)/`):
`feature/e8.2-phase0-coverage-infra`, `feature/e8.2-core-tests`, etc.

---

## 8. Precondición de entorno

`melos bootstrap` tiene que correr antes de los tests. Durante la exploración, los 36 tests
de `order_tracking` fallaban en local por un `package_config.json` desactualizado que no
resolvía `package:profile` — no era un bug del código. CI ya hace bootstrap; el runbook
local tiene que decirlo explícitamente.

---

## 9. GitHub: epic, issues y board

**Repo**: `Warehouse-USAL/SmartWarehouse`. **Board**: proyecto `wh-mobile` del mismo repo.

### 9.1 Estado actual del árbol E8

Ya existe estructura; este trabajo **se integra en ella, no la duplica**:

| Issue | Estado | Acción |
|---|---|---|
| #129 `E8.2: Cubrir el código 100% con tests unitarios` | body vacío | Reescribir como epic con targets escalonados |
| #130 `E8.2.1: Cambiar el PR para que haga un check...` | body vacío | **Ya es la Fase 0**; se le escribe el body, no se crea un issue nuevo |
| #126 `E8.1: Tests integrales` | body vacío | Pertenece al trabajo de Patrol. Fuera de alcance (§9.4) |
| #131 + #134–139, #151, #152, #154 (`E8.3.x`) | bodies completos | Trabajo de Patrol, de otro dev. No se toca. |

**E8.2 (#129) se reescribe como epic**: pasa de "100% con tests unitarios" a los targets
escalonados, con este spec linkeado. 100% de cobertura no es un objetivo estándar de
industria — obliga a testear código generado y glue de UI, y premia inflar el número.

### 9.2 Sub-issues

Se sigue la numeración `E8.2.x` y el formato de body de la casa
(*Contexto / Alcance / Decisiones / Criterio de aceptación*, abriendo con "Parte de la épica #129").

| ID | Alcance | Fase |
|---|---|---|
| E8.2.1 (#130, existe) | Infra de cobertura: thresholds, `check_coverage.dart`, `gen_coverage_imports.dart`, fix de melos, job de CI | 0 |
| E8.2.2 | `packages/test_support` | 0 |
| E8.2.3 | Reescribir `ARCHITECTURE.md` §18 | 0 |
| E8.2.4–6 | `core`, `commons`, `token_repository` | 1 |
| E8.2.7–13 | `auth`, `cart`, `orders`, `order_tracking`, `login`, `catalog`, `profile` | 2 |
| E8.2.14–15 | `bottom_navigation_bar`, `design_system` | 3 |

14 issues nuevos (E8.2.2–E8.2.15) más el body de #130. Cada uno lleva: package, % actual,
% target, checklist de archivos y criterio de aceptación.

### 9.3 Labels

Se reutiliza la taxonomía existente: `area:qa` en todos, `type:epic` en #129,
`priority:P1` en Fases 0–1 y `priority:P2` en Fases 2–3. **No** se aplican labels `sprint:*`
— las que existen llegan hasta `sprint:3` (27/05–17/06) y están vencidas.

### 9.4 Fuera de alcance

`E8.1: Tests integrales` (#126) pertenece al trabajo de Patrol, igual que la serie E8.3.x.
No se toca desde este spec.

### 9.5 Requisito de auth

`gh` corre vía `flatpak-spawn --host` (ver §12). El token actual tiene scopes
`gist`, `read:org`, `repo`, `workflow` — alcanza para issues, **no para el board**.
Escribir en el proyecto `wh-mobile` requiere `gh auth refresh -s project`.

---

## 10. Frontera con Patrol

Se documenta en `ARCHITECTURE.md` para que sea un contrato compartido y no un acuerdo verbal:

- **Este trabajo** es dueño de `packages/*/test/` (unit + widget).
- **El trabajo de Patrol** es dueño de `integration_test/` en la raíz (E2E).
- Fase 0 fija los nombres de los jobs de CI (`analyze`, `test`, `coverage`) para que el otro
  dev **agregue** un job `e2e` en lugar de reestructurar los existentes.
- El branch de Patrol rebasa después de que Fase 0 mergea.

Las pages quedan deliberadamente fuera del unit testing (§4.1) justamente para no duplicar
lo que cubre Patrol.

### 10.1 Puntos de contacto concretos (leídos de los issues E8.3.x)

| Issue de Patrol | Contacto | Resolución |
|---|---|---|
| #152 (CI e2e) | Define el e2e como **workflow separado** (docker-compose + emulador Android, PRs a develop o nightly) | Sin conflicto: agrega, no reestructura. Confirma el supuesto de §10. |
| #135 (keys de testing en design system) | Agrega `Key`s a widgets de `design_system` para que Patrol los seleccione | **Sin dependencia.** Agregar keys es aditivo: no rompe widget tests. Fase 3 no espera. |
| #134 (setup de Patrol) | Agrega `patrol` + bloque `patrol:` al `pubspec.yaml` raíz | Solapamiento menor: Fase 0 también toca pubspecs. Merge trivial. |

---

## 11. Riesgos

| Riesgo | Mitigación |
|---|---|
| Los floors sembrados salen más bajos que la tabla de §1 y parece un retroceso | Documentar que la baseline vieja incluía código generado; la nueva medición es la honesta. |
| `design_system` al 40% igual es mucho trabajo (3.190 LOC) | Está en Fase 3, después de que el gate ya protege las capas de lógica. |
| El branch de Patrol mergea antes que Fase 0 | Los dueños de archivos no se solapan; solo hay que resolver `ci.yml` a mano. |
| Los tests de widget quedan frágiles por cambios de layout | Solo se testean componentes con lógica; los de layout puro quedan fuera por convención. |
| Los widget tests de Fase 3 chocan con las `Key`s que agrega #135 | Bajo: agregar keys es aditivo. Si aparece ruido, se resuelve en el PR de Fase 3. |

---

## 12. Nota de entorno: `gh` dentro del sandbox de Flatpak

El entorno de desarrollo corre dentro del Flatpak de VSCodium (`com.vscodium.codium`).
`gh` instalado *dentro* del sandbox reporta "not logged into any GitHub hosts" aunque el
login en el host haya sido exitoso:

- `~/.config/gh/hosts.yml` es visible desde el sandbox, pero **no contiene el token** — solo
  nombra la cuenta. `gh` guarda el token real en el keyring de GNOME.
- El proxy de D-Bus del sandbox permite hacer *ping* al secret service pero no recuperar
  secretos, así que el `gh` del sandbox ve una cuenta sin credencial.

**Solución**: prefijar los comandos con `flatpak-spawn --host`, que ejecuta el `gh` del host
con su acceso al keyring intacto.

```bash
flatpak-spawn --host gh issue list --repo Warehouse-USAL/SmartWarehouse
```

No hace falta `GH_TOKEN` ni guardar el token en texto plano.
