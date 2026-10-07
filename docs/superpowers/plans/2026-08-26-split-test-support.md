# Partir `test_support` — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que `test_support` deje de depender de packages de features, y que esa regla quede verificada por un test en CI en vez de por un comentario.

**Architecture:** Hoy `test_support` mezcla dos cosas con dependencias distintas: mocks e infraestructura de injector (necesitan solo `commons`) y builders de entities (necesitan `catalog`). Se separan en dos packages: `test_support` queda con mocks + injector + fixtures y depende solo de `commons`; los builders se van a `catalog_test_builders`, que depende de `catalog`. Un test de guarda en `test/tool/` fija la regla para que no vuelva a filtrarse una feature.

**Tech Stack:** Dart/Flutter, melos 6.3.3, mocktail, flutter_test.

**Spec:** `docs/superpowers/specs/2026-08-12-test-strategy-design.md` — §4.3 (`packages/test_support`) y §5 (exclusiones del gate). Este plan además **modifica** §4.3; el texto nuevo está en la Task 5.

**Issue:** #184. Épica: #129.

## Global Constraints

- Dart SDK: `>=3.8.0 <4.0.0` en todo package nuevo.
- `mocktail: ^1.0.4` — la versión que ya usan los 5 packages con tests.
- `flutter_lints: ^5.0.0` como dev-dependency de todo package nuevo.
- Todo package de soporte de tests lleva `publish_to: none` y queda **fuera del gate de cobertura**: no se agrega a `coverage_thresholds.yaml`. `tool/gen_coverage_imports.dart` solo itera los packages listados ahí, así que no listarlo alcanza.
- `melos.yaml` declara `packages: ['*', 'packages/**']`: un directorio nuevo bajo `packages/` entra al workspace solo. No hay que editar `melos.yaml`.
- Los `pubspec_overrides.yaml` los genera `melos bootstrap`. **No editarlos a mano** — llevan un header `# melos_managed_dependency_overrides:`.
- Idioma de comentarios y docs: español, como el resto del repo.
- Los floors de `coverage_thresholds.yaml` **no se tocan** en este plan. Ningún cambio acá altera código de `lib/`.

---

## Estado de partida (verificado sobre `origin/develop` @ `5945403`)

`packages/test_support/lib/` contiene:

```
src/builders/money_builder.dart      -> import 'package:catalog/catalog.dart'
src/builders/product_builder.dart    -> import 'package:catalog/catalog.dart'
src/builders/stock_builder.dart      -> import 'package:catalog/catalog.dart'
src/fixtures.dart                    -> dart:convert, dart:io
src/injector_harness.dart            -> import 'package:commons/commons.dart'
src/mocks.dart                       -> commons + mocktail
```

Los 16 archivos de test que importan `package:test_support/test_support.dart`, y qué símbolo usa cada uno. **No hay un solo archivo que use las dos mitades** — por eso cada import se reemplaza, nunca se duplica:

| Archivo | Usa | Queda con |
|---|---|---|
| `commons/test/utils/image_url_resolver_test.dart` | `MockHttpHelper`, `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_get_token_use_case_test.dart` | `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_intercept_http_request_use_case_test.dart` | `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_login_navigation_use_case_test.dart` | `MockNavigationHelper`, `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_login_use_case_test.dart` | `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_logout_use_case_test.dart` | `registerMock`, `resetInjector` | `test_support` |
| `core/test/use_cases/on_user_authenticated_use_case_test.dart` | `MockNavigationHelper`, `registerMock`, `resetInjector` | `test_support` |
| `features/auth/test/auth_feature_builder_test.dart` | `MockHttpHelper`, `MockPersistenceHelper`, `registerMock`, `resetInjector` | `test_support` |
| `features/auth/test/data/repositories/local_auth_repository_test.dart` | `MockHttpHelper`, `MockPersistenceHelper` | `test_support` |
| `features/auth/test/data/repositories/mock_local_auth_repository_test.dart` | `MockPersistenceHelper` | `test_support` |
| `features/cart/test/data/repositories/in_memory_cart_repository_test.dart` | `aProduct` | **`catalog_test_builders`** |
| `features/cart/test/domain/entities/cart_test.dart` | `aMoney`, `aProduct` | **`catalog_test_builders`** |
| `features/cart/test/presentation/bloc/cart_cubit_test.dart` | `aProduct` | **`catalog_test_builders`** |
| `features/cart/test/presentation/widgets/cart_badge_test.dart` | `aProduct`, `aStock` | **`catalog_test_builders`** |
| `features/cart/test/presentation/widgets/cart_item_tile_test.dart` | `aProduct` | **`catalog_test_builders`** |
| `features/cart/test/presentation/widgets/create_order_confirmation_dialog_test.dart` | `aMoney`, `aProduct` | **`catalog_test_builders`** |

`loadJsonFixture` no tiene ningún consumidor todavía (se construyó por adelantado, decisión 15 del registro). Se queda en `test_support`.

`packages/features/repositories/token_repository/pubspec.yaml` declara `test_support` como dev-dependency pero **ningún** test suyo lo importa. Es una dependencia muerta; la Task 4 la saca.

### Layout objetivo

```
packages/test_support/                 deps: commons, mocktail   (+ flutter, flutter_test)
  lib/test_support.dart
  lib/src/fixtures.dart
  lib/src/injector_harness.dart
  lib/src/mocks.dart

packages/catalog_test_builders/        deps: catalog             (+ flutter)
  lib/catalog_test_builders.dart
  lib/src/builders/money_builder.dart
  lib/src/builders/product_builder.dart
  lib/src/builders/stock_builder.dart
```

---

## Task 1: Crear `catalog_test_builders` con los builders movidos

**Files:**
- Create: `packages/catalog_test_builders/pubspec.yaml`
- Create: `packages/catalog_test_builders/lib/catalog_test_builders.dart`
- Create: `packages/catalog_test_builders/lib/src/builders/money_builder.dart`
- Create: `packages/catalog_test_builders/lib/src/builders/product_builder.dart`
- Create: `packages/catalog_test_builders/lib/src/builders/stock_builder.dart`
- Test: `packages/catalog_test_builders/test/builders_test.dart`

**Interfaces:**
- Consumes: nada de tareas anteriores.
- Produces: `package:catalog_test_builders/catalog_test_builders.dart` exportando
  `Money aMoney({int amount, String currency, bool? taxIncluded})`,
  `Stock aStock({int available, int? min, int? reserved, int? lowStockThreshold})`,
  `Product aProduct({String id, String sku, String name, ProductCategory category, Money? price, Stock? stock, OrderConstraints? orderConstraints, String? imageUrl, String? description})`.
  Las Tasks 2 y 3 dependen de estos nombres exactos.

En esta tarea el package **se crea al lado** del existente. `test_support` todavía conserva sus builders: nada se rompe, y la Task 3 los saca recién cuando ya nadie los usa desde ahí.

- [ ] **Step 1: Crear el pubspec del package nuevo**

`packages/catalog_test_builders/pubspec.yaml`:

```yaml
name: catalog_test_builders
description: Builders de entities de catalog para tests. No se publica ni entra en el bundle de la app.
version: 0.0.1
publish_to: none

environment:
  sdk: '>=3.8.0 <4.0.0'

dependencies:
  catalog:
    path: ../features/catalog
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

- [ ] **Step 2: Copiar los tres builders sin tocar el contenido**

Los archivos se mueven tal cual: mismos defaults, mismos comentarios. Cambiar el comportamiento de un builder acá haría que un fallo de test en la Task 2 sea ambiguo entre "el movimiento salió mal" y "el default cambió".

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
mkdir -p packages/catalog_test_builders/lib/src/builders
cp packages/test_support/lib/src/builders/money_builder.dart \
   packages/test_support/lib/src/builders/product_builder.dart \
   packages/test_support/lib/src/builders/stock_builder.dart \
   packages/catalog_test_builders/lib/src/builders/
```

Verificar que los tres quedaron y que siguen importando `package:catalog/catalog.dart`:

```bash
grep -l "package:catalog/catalog.dart" packages/catalog_test_builders/lib/src/builders/*.dart
```

Esperado: los tres archivos listados.

- [ ] **Step 3: Escribir el barrel file**

`packages/catalog_test_builders/lib/catalog_test_builders.dart`:

```dart
library catalog_test_builders;

export 'src/builders/money_builder.dart';
export 'src/builders/product_builder.dart';
export 'src/builders/stock_builder.dart';
```

- [ ] **Step 4: Escribir el test del package**

`packages/catalog_test_builders/test/builders_test.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aMoney', () {
    test('usa un default distinto de cero para no esconder bugs de suma', () {
      final money = aMoney();

      expect(money.amount, 1000);
      expect(money.currency, 'ARS');
    });

    test('respeta los overrides', () {
      final money = aMoney(amount: 250, currency: 'USD', taxIncluded: true);

      expect(money.amount, 250);
      expect(money.currency, 'USD');
      expect(money.taxIncluded, isTrue);
    });
  });

  group('aStock', () {
    test('deja el producto comprable sin estar en stock bajo', () {
      expect(aStock().available, 10);
    });

    test('respeta los overrides', () {
      expect(aStock(available: 0).available, 0);
    });
  });

  group('aProduct', () {
    test('arma un producto completo con price y stock por defecto', () {
      final product = aProduct();

      expect(product.id, 'p-1');
      expect(product.sku, 'SKU-1');
      expect(product.category, ProductCategory.herramientas);
      expect(product.price.amount, 1000);
      expect(product.stock.available, 10);
      // `orderConstraints` es no-nullable en Product: sin `?.`, que el
      // analizador marcaria como unnecessary_null_comparison.
      expect(product.orderConstraints.maxQuantityPerOrder, 5);
    });

    test('acepta price y stock explicitos', () {
      final product = aProduct(price: aMoney(amount: 5), stock: aStock(available: 1));

      expect(product.price.amount, 5);
      expect(product.stock.available, 1);
    });

    test('Product define == solo por id', () {
      expect(aProduct(id: 'x', name: 'uno'), aProduct(id: 'x', name: 'otro'));
      expect(aProduct(id: 'x'), isNot(aProduct(id: 'y')));
    });
  });
}
```

- [ ] **Step 5: Bootstrap y correr el test**

`melos bootstrap` genera el `pubspec_overrides.yaml` del package nuevo. Tarda unos minutos.

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
melos bootstrap
cd packages/catalog_test_builders && flutter test
```

Esperado: PASS, 7 tests.

Si falla con `Target of URI doesn't exist: 'package:catalog_test_builders/...'`, el bootstrap no tomó el package: confirmar que `packages/catalog_test_builders/pubspec.yaml` existe y volver a correr `melos bootstrap`.

- [ ] **Step 6: Commit**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git add packages/catalog_test_builders
git commit -m "test(support): crear catalog_test_builders con los builders de entities

Los builders de Money/Product/Stock necesitan catalog; los mocks y el
injector harness no. Separarlos permite que test_support deje de arrastrar
features al binario de tests de commons, core y auth.

Todavia no se sacan de test_support: eso va cuando cart deje de usarlos
desde ahi (#184)."
```

---

## Task 2: Apuntar `cart` al package nuevo

**Files:**
- Modify: `packages/features/cart/pubspec.yaml` (bloque `dev_dependencies`)
- Modify: `packages/features/cart/test/data/repositories/in_memory_cart_repository_test.dart:3`
- Modify: `packages/features/cart/test/domain/entities/cart_test.dart:4`
- Modify: `packages/features/cart/test/presentation/bloc/cart_cubit_test.dart:6`
- Modify: `packages/features/cart/test/presentation/widgets/cart_badge_test.dart:7`
- Modify: `packages/features/cart/test/presentation/widgets/cart_item_tile_test.dart:5`
- Modify: `packages/features/cart/test/presentation/widgets/create_order_confirmation_dialog_test.dart:6`

**Interfaces:**
- Consumes: `package:catalog_test_builders/catalog_test_builders.dart` (`aMoney`, `aProduct`, `aStock`) de la Task 1.
- Produces: `cart` sin dev-dependency a `test_support`. La Task 3 cuenta con eso para poder borrar los builders.

`cart` es el único consumidor de builders, y no usa ningún mock ni el injector harness (ver la tabla de arriba). Por eso el swap es total: sale `test_support`, entra `catalog_test_builders`.

- [ ] **Step 1: Correr los tests de cart antes de tocar nada**

Sirve de línea de base: si algo falla después, hay que saber si ya fallaba.

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/cart
flutter test
```
Esperado: PASS. Anotar cuántos tests corrieron.

- [ ] **Step 2: Cambiar la dev-dependency**

En `packages/features/cart/pubspec.yaml`, dentro de `dev_dependencies`, reemplazar:

```yaml
  test_support:
    path: ../../test_support
```

por:

```yaml
  catalog_test_builders:
    path: ../../catalog_test_builders
```

- [ ] **Step 3: Cambiar los 6 imports**

Todos son la misma línea exacta, `import 'package:test_support/test_support.dart';`, y ninguno de los 6 archivos usa además un símbolo de `test_support`, así que se reemplaza en vez de agregar:

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
sed -i "s|import 'package:test_support/test_support.dart';|import 'package:catalog_test_builders/catalog_test_builders.dart';|" \
  packages/features/cart/test/data/repositories/in_memory_cart_repository_test.dart \
  packages/features/cart/test/domain/entities/cart_test.dart \
  packages/features/cart/test/presentation/bloc/cart_cubit_test.dart \
  packages/features/cart/test/presentation/widgets/cart_badge_test.dart \
  packages/features/cart/test/presentation/widgets/cart_item_tile_test.dart \
  packages/features/cart/test/presentation/widgets/create_order_confirmation_dialog_test.dart
```

Verificar que no quedó ninguna referencia vieja en `cart`:

```bash
grep -rn "package:test_support" packages/features/cart/ || echo "OK: sin referencias a test_support"
```
Esperado: `OK: sin referencias a test_support`.

- [ ] **Step 4: Bootstrap y correr los tests de cart**

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
melos bootstrap
cd packages/features/cart && flutter test
```
Esperado: PASS, la misma cantidad de tests que en el Step 1.

- [ ] **Step 5: Commit**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git add packages/features/cart
git commit -m "test(cart): tomar los builders de catalog_test_builders

cart es el unico package que usa aProduct/aMoney/aStock, y no usa ningun
mock ni el injector harness, asi que el swap de dependencia es total."
```

---

## Task 3: Sacar los builders de `test_support` y fijar la regla con un test

**Files:**
- Create: `test/tool/test_support_deps_test.dart`
- Delete: `packages/test_support/lib/src/builders/money_builder.dart`
- Delete: `packages/test_support/lib/src/builders/product_builder.dart`
- Delete: `packages/test_support/lib/src/builders/stock_builder.dart`
- Modify: `packages/test_support/lib/test_support.dart`
- Modify: `packages/test_support/pubspec.yaml`

**Interfaces:**
- Consumes: `cart` ya no depende de `test_support` (Task 2).
- Produces: `test_support` con dependencias `{flutter, flutter_test, commons, mocktail}` y sin builders.

El test de guarda va acá y no antes porque acá es donde su ciclo rojo→verde es corto: se escribe, falla contra el `pubspec.yaml` actual, y se pone en verde en el mismo tramo al sacar la dependencia.

El test corre en CI: el job `Coverage gate` ejecuta `flutter test test/tool` antes del gate de cobertura. El package raíz no está en el workspace de melos, así que `melos run test` **no** lo levanta — por eso el archivo va en `test/tool/`, que es lo que CI invoca explícitamente.

- [ ] **Step 1: Escribir el test de guarda**

`test/tool/test_support_deps_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lo unico que `test_support` puede tener en `dependencies`.
///
/// La regla del spec §4.3: `test_support` no depende de packages de features.
/// Cuando lo hacia (dependia de `catalog`), el binario de tests de `commons`
/// compilaba catalog, design_system y bottom_navigation_bar por un archivo que
/// solo queria MockHttpHelper.
///
/// Agregar algo a esta lista es una decision de diseno, no un tramite: si un
/// helper nuevo necesita una feature, va a un package `<feature>_test_builders`
/// aparte, no aca.
const _allowed = {'flutter', 'flutter_test', 'commons', 'mocktail'};

/// Devuelve los nombres declarados bajo `dependencies:` de un pubspec.
///
/// Parseo por lineas a proposito: el repo no tiene el package `yaml` como
/// dependencia y `tool/coverage/thresholds.dart` ya resuelve su YAML asi.
/// Un pubspec tiene sangria fija, con lo cual alcanza con mirar la columna.
Set<String> _dependencyNames(String pubspec) {
  final names = <String>{};
  var inDependencies = false;

  for (final line in const LineSplitter().convert(pubspec)) {
    if (line.trimRight() == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    // Cualquier clave de nivel cero cierra el bloque.
    if (inDependencies &&
        line.isNotEmpty &&
        !line.startsWith(' ') &&
        !line.startsWith('#')) {
      inDependencies = false;
    }
    if (!inDependencies) continue;

    final match = RegExp(r'^  ([a-z0-9_]+):').firstMatch(line);
    if (match != null) names.add(match.group(1)!);
  }

  return names;
}

void main() {
  test('test_support solo depende de commons y mocktail', () {
    final pubspec = File('packages/test_support/pubspec.yaml');
    expect(
      pubspec.existsSync(),
      isTrue,
      reason: 'correr desde la raiz del repo (cwd: ${Directory.current.path})',
    );

    final declared = _dependencyNames(pubspec.readAsStringSync());
    final extra = declared.difference(_allowed);

    expect(
      extra,
      isEmpty,
      reason:
          'test_support no puede depender de packages de features (spec §4.3). '
          'Si el helper nuevo necesita una feature, va a <feature>_test_builders.',
    );
  });

  test('el parser lee las dependencias y corta en la clave siguiente', () {
    const pubspec = '''
name: ejemplo

dependencies:
  commons:
    path: ../commons
  mocktail: ^1.0.4

dev_dependencies:
  flutter_lints: ^5.0.0
''';

    expect(_dependencyNames(pubspec), {'commons', 'mocktail'});
  });
}
```

- [ ] **Step 2: Correr el test y verificar que falla**

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
flutter test test/tool/test_support_deps_test.dart
```
Esperado: **FAIL** en el primer test, con `Expected: empty / Actual: {'catalog'}`. El segundo test (el del parser) pasa.

Si el primero pasa acá, el parser está mal: `catalog` está declarado en el pubspec y tiene que detectarlo. Revisar la regex y la sangría antes de seguir.

- [ ] **Step 3: Borrar los builders y su export**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
rm -r packages/test_support/lib/src/builders
```

`packages/test_support/lib/test_support.dart` queda:

```dart
library test_support;

export 'src/fixtures.dart';
export 'src/injector_harness.dart';
export 'src/mocks.dart';
```

- [ ] **Step 4: Sacar `catalog` del pubspec**

`packages/test_support/pubspec.yaml`, bloque `dependencies`, queda:

```yaml
dependencies:
  commons:
    path: ../commons
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
```

`flutter_test` se queda: `test_support` es una librería de soporte de tests y sus consumidores la cargan desde `test/`. Sacarla es una discusión aparte y no la pide #184.

- [ ] **Step 5: Correr el test de guarda y verificar que pasa**

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
melos bootstrap
flutter test test/tool/test_support_deps_test.dart
```
Esperado: PASS, 2 tests.

- [ ] **Step 6: Verificar que los consumidores que quedan siguen verdes**

Son los tres packages que usan solo mocks e injector:

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
(cd packages/commons && flutter test)
(cd packages/core && flutter test)
(cd packages/features/auth && flutter test)
```
Esperado: PASS los tres.

- [ ] **Step 7: Commit**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git add packages/test_support test/tool/test_support_deps_test.dart
git commit -m "test(support): test_support deja de depender de catalog

Los builders ya viven en catalog_test_builders y cart los toma de ahi, asi
que test_support puede quedarse solo con mocks, injector harness y fixtures.

El test de guarda en test/tool/ hace vinculante la regla del spec 4.3: antes
vivia en un comentario en auth_builders.dart y nada la verificaba."
```

---

## Task 4: Sacar la dev-dependency muerta de `token_repository`

**Files:**
- Modify: `packages/features/repositories/token_repository/pubspec.yaml` (bloque `dev_dependencies`)

**Interfaces:**
- Consumes: nada.
- Produces: nada que consuman otras tareas.

`token_repository` declara `test_support` pero ningún test suyo lo importa — se verificó con un grep sobre los 16 consumidores reales. Es ruido que hace parecer que el package necesita algo que no necesita.

- [ ] **Step 1: Confirmar que efectivamente no lo usa**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
grep -rn "package:test_support" packages/features/repositories/token_repository/ \
  || echo "OK: no lo importa, la dependencia es muerta"
```
Esperado: `OK: no lo importa, la dependencia es muerta`.

Si aparece alguna referencia, **saltear esta tarea entera** y dejar la dependencia donde está.

- [ ] **Step 2: Sacar el bloque**

En `packages/features/repositories/token_repository/pubspec.yaml`, borrar de `dev_dependencies`:

```yaml
  test_support:
    path: ../../../test_support
```

- [ ] **Step 3: Verificar que los tests siguen pasando**

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
melos bootstrap
(cd packages/features/repositories/token_repository && flutter test)
```
Esperado: PASS. `token_repository` está en 100% de cobertura, así que cualquier import roto sale acá.

- [ ] **Step 4: Commit**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git add packages/features/repositories/token_repository/pubspec.yaml
git commit -m "chore(token-repository): sacar dev-dependency muerta a test_support

Ningun test del package lo importa."
```

---

## Task 5: Hacer vinculante la regla en el spec

**Files:**
- Modify: `docs/superpowers/specs/2026-08-12-test-strategy-design.md` (§4.3 completa, y la fila `test_support` de la tabla de §5)
- Modify: `packages/features/auth/test/support/auth_builders.dart` (comentario de cabecera)

**Interfaces:**
- Consumes: el layout de packages de las Tasks 1 y 3.
- Produces: nada de código.

La regla de ≥2 hoy vive **solo** en un comentario dentro de `auth_builders.dart`. El spec §4.3 ni la menciona, y encima describe un `test_support` que tiene builders adentro — lo contrario de lo que queda después de este plan.

- [ ] **Step 1: Reemplazar §4.3 completa**

En `docs/superpowers/specs/2026-08-12-test-strategy-design.md`, reemplazar la sección `### 4.3 packages/test_support` entera (desde el encabezado hasta la línea `---` que la cierra) por:

```markdown
### 4.3 Packages de soporte de tests

Dos packages, separados por sus dependencias. Los dos son solo para desarrollo:
`publish_to: none`, no entran en el bundle de la app y quedan **fuera del gate de
cobertura** (§5).

**`packages/test_support`** — depende solo de `commons`.

- **Mocks compartidos** de `mocktail` y sus `registerFallbackValue`.
- **Injector harness**: `resetInjector()`, `registerMock<T>()`.
- **Carga de fixtures JSON**: helper para leer los golden files del contrato.

**`packages/<feature>_test_builders`** — uno por feature que define las entities.
Hoy existe `catalog_test_builders` (`aMoney`, `aProduct`, `aStock`).

#### La regla

> Un builder va a un package compartido **solo si lo necesitan dos o más
> packages**. Si lo necesita uno solo, vive en el `test/support/` de ese package.

Y su contrapartida, que es la que se pasó por alto la primera vez:

> **`test_support` no depende de packages de features.** Un helper que necesita una
> feature va a `<feature>_test_builders`, nunca a `test_support`.

Motivo: `test_support` declaraba `catalog` —una feature— entre sus dependencias, y de
sus cinco consumidores, cuatro no usaban un solo builder. Un package de soporte que
arrastra features hacia que cada consumidor cargara con el grafo entero por un archivo
que solo quería `MockHttpHelper`, y creaba un ciclo de dev-dependency
`commons →(dev) test_support → catalog → … → commons`.

> **Lo que esto NO arregla.** Al separarlos se midió si `commons` dejaba de resolver
> `catalog`, `design_system` y `bottom_navigation_bar`. **No lo hace**, y la causa es
> anterior e independiente: `commons` depende de `core` (dependencia de producción), y
> `core` depende de `auth`, `login`, `bottom_navigation_bar`, `catalog`, `cart`,
> `orders`, `order_tracking` y `token_repository`. Como `core` a su vez depende de
> `commons`, **`core ↔ commons` es un ciclo de dependencias de producción**. La arista
> `test_support → catalog` era redundante sobre un grafo que ya estaba completo.
>
> Sacarla igual vale: la capa de soporte de tests queda con un grafo honesto y la regla
> es verificable. Pero adelgazar los binarios de test exige romper `core → features`,
> que es un problema aparte y mucho mayor.

La regla está verificada por `test/tool/test_support_deps_test.dart`, que corre en
CI dentro del job `Coverage gate`. No es una convención documentada: si alguien
agrega una feature a `test_support`, CI se pone en rojo.

Sobre la duplicación que motivaba el package original: `order_tracking`
reimplementa a mano un `_FakeCatalog` que los tests de `catalog` ya definen, con
los tres métodos no usados devolviendo `Left(CatalogFailure('not used'))`. Eso lo
resuelve un builder compartido en `catalog_test_builders`, que es donde
corresponde, no un package que junta todo.

---
```

- [ ] **Step 2: Actualizar la fila de la tabla de §5**

En la tabla de umbrales de §5, la fila:

```markdown
| `test_support` | excluido | Es código de test. |
```

pasa a:

```markdown
| `test_support` | excluido | Es código de test. |
| `<feature>_test_builders` | excluido | Es código de test. |
```

- [ ] **Step 3: Actualizar el comentario que tenía la regla**

En `packages/features/auth/test/support/auth_builders.dart`, el comentario de cabecera de `anAuthData` dice hoy:

```dart
/// Vive acá y no en `test_support` porque `AuthData` lo usa solo este package:
/// centralizarlo obligaría a `test_support` a depender de `auth`.
```

Reemplazarlo por:

```dart
/// Vive acá y no en un package compartido porque `AuthData` lo usa solo este
/// package. La regla está en el spec §4.3: un builder se comparte solo si lo
/// necesitan dos o más packages, y `test_support` nunca depende de una feature.
```

- [ ] **Step 4: Verificar que el analizador sigue limpio**

Run:
```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
(cd packages/features/auth && flutter analyze)
```
Esperado: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git add docs/superpowers/specs/2026-08-12-test-strategy-design.md \
        packages/features/auth/test/support/auth_builders.dart
git commit -m "docs(test): spec 4.3 describe los dos packages de soporte y la regla

La regla de >=2 vivia en un comentario en auth_builders.dart y el spec
describia un test_support con builders adentro, que es lo contrario de lo que
quedo. Ahora ademas la verifica un test en CI."
```

---

## Task 6: Verificación completa y PR

**Files:** ninguno nuevo.

**Interfaces:**
- Consumes: todo lo anterior.
- Produces: el PR de #184.

- [ ] **Step 1: Confirmar que ningún package quedó apuntando al lugar viejo**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
echo "--- quien declara test_support ---"
grep -rln "test_support" --include=pubspec.yaml packages/ .
echo "--- quien lo importa ---"
grep -rn "package:test_support" --include=*.dart packages/
```

Esperado en el primero: `packages/commons`, `packages/core`, `packages/features/auth`, y el propio `packages/test_support`. **No** debe aparecer `cart` ni `token_repository`.
Esperado en el segundo: los 10 archivos de `commons`, `core` y `auth`. Ninguno de `cart`.

- [ ] **Step 2: Analizar todo el workspace**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
melos exec -- flutter analyze
flutter analyze
```
Esperado: sin issues en ningún package. El segundo comando cubre `tool/` y `test/tool/`, que no están en el workspace de melos.

- [ ] **Step 3: Correr la suite completa con el gate de cobertura**

Este es el comando que corre CI.

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
flutter test test/tool
melos run test:coverage
```

Esperado: PASS, y el reporte del gate sin ningún package por debajo de su floor.

Los floors **no** deberían moverse: este plan no toca una sola línea de `lib/` de ningún package medido. Si algún porcentaje cambió, es una señal de que algo se movió de lugar sin querer — investigar antes de seguir, no re-ratchetear.

- [ ] **Step 4: Confirmar el invariante que este cambio sí garantiza**

> **Corrección al plan (2026-08-26, tras ejecutar la Task 3).** Este step decía antes
> que había que verificar que `commons` dejaba de resolver `catalog`, `design_system` y
> `bottom_navigation_bar`, y esperaba `OK`. **Eso es falso y se midió.** El motivo por el
> que `commons` arrastra features no era `test_support`:
>
> ```
> packages/commons/pubspec.yaml:10   commons -> core          (dependencia de produccion)
> packages/core/pubspec.yaml         core    -> auth, login, bottom_navigation_bar,
>                                               catalog, cart, orders, order_tracking,
>                                               token_repository
> ```
>
> `commons` depende de `core`, y `core` depende de casi todas las features, así que
> `commons` las arrastra por su grafo de producción, independientemente de
> `test_support`. Y como `core` a su vez depende de `commons`, **`core ↔ commons` es un
> ciclo de dependencias de producción real.** La arista `test_support → catalog` era una
> arista redundante sobre un grafo que ya estaba completo.
>
> Sacarla sigue valiendo la pena —`test_support` ya no declara una feature, el ciclo de
> dev-dependency desapareció, la regla la verifica CI y los builders de `Order` para #163
> y #164 tienen dónde vivir— pero **no** adelgaza ningún binario de tests. Eso necesita
> romper `core → features`, que es un problema aparte y mucho más grande.

Lo que sí garantiza este cambio, y es lo que hay que verificar:

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
sed -n '/^dependencies:/,/^dev_dependencies:/p' packages/test_support/pubspec.yaml
```
Esperado: exactamente `commons`, `flutter`, `flutter_test` y `mocktail`. Ninguna feature.

Y que el guard test lo mantenga así:

```bash
flutter test test/tool/test_support_deps_test.dart
```
Esperado: PASS, 2 tests.

Dejar constancia del hallazgo de `core ↔ commons` en un issue nuevo, con los números de
arriba. No se arregla acá.

- [ ] **Step 5: Abrir el PR**

La convención de nombres de rama la valida el job `validate-branch` de CI: tiene que empezar con `feature/`, `fix/`, `enhancement/`, `refactor/`, `hotfix/`, `beta/`, `backport/` o `dependabot/`.

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
git push -u origin refactor/e8.2-split-test-support
gh pr create --base develop \
  --title "refactor(test): partir test_support para que no dependa de las features" \
  --body "Cierra #184.

\`test_support\` dependia de \`catalog\`, una feature, aunque cuatro de sus cinco
consumidores no usaban un solo builder.

## Correccion sobre la justificacion original

El issue decia que por esa arista el binario de tests de \`commons\` compilaba
catalog, design_system y bottom_navigation_bar. **Se midio y es falso.** El
motivo real es otro y es anterior:

\`\`\`
packages/commons/pubspec.yaml:10   commons -> core   (dependencia de produccion)
packages/core/pubspec.yaml         core    -> auth, login, bottom_navigation_bar,
                                              catalog, cart, orders,
                                              order_tracking, token_repository
\`\`\`

\`commons\` arrastra casi todas las features por \`core\`, independientemente de
\`test_support\`. Y \`core\` depende de \`commons\`, con lo cual \`core <-> commons\` es
un ciclo de dependencias de produccion. La arista \`test_support -> catalog\` era
redundante sobre un grafo ya completo.

**Este PR no adelgaza ningun binario de tests.** Lo que si hace:

- \`test_support\` ya no declara una feature entre sus dependencias
- desaparece el ciclo de dev-dependency \`commons ->dev test_support -> catalog -> ... -> commons\`
- la regla pasa de un comentario a un test que corre en CI
- los builders de \`Order\` que van a compartir #163 y #164 tienen donde vivir

El \`core <-> commons\` queda para registrar en un issue aparte.

De los 16 archivos que importaban \`test_support\`, 10 usaban solo mocks e
injector y 6 (todos de \`cart\`) usaban solo builders. Ninguno usaba las dos
mitades, asi que la separacion es limpia:

- \`test_support\` -> mocks + injector harness + fixtures. Depende solo de \`commons\`.
- \`catalog_test_builders\` -> aMoney/aProduct/aStock. Depende de \`catalog\`.

La regla del spec 4.3 queda verificada por \`test/tool/test_support_deps_test.dart\`,
que corre en CI: si alguien vuelve a meter una feature en \`test_support\`, se pone
en rojo. Antes vivia en un comentario en \`auth_builders.dart\`.

Tambien saca una dev-dependency muerta de \`token_repository\`.

Desbloquea #166 (catalog) y da lugar a los builders de \`Order\` que van a
compartir #163 y #164.

## Verificacion

- \`melos exec -- flutter analyze\` y \`flutter analyze\` limpios
- \`flutter test test/tool\` PASS
- \`melos run test:coverage\` PASS, sin cambios en los floors
- \`test_support\` declara exactamente commons, flutter, flutter_test y mocktail"
```

---

## Self-review

**Cobertura del spec.** §4.3 se reescribe en la Task 5 y el layout que describe lo construyen las Tasks 1 y 3. La fila de §5 que excluye el soporte de tests del gate se extiende al package nuevo en la Task 5 Step 2, y el mecanismo real (no listarlo en `coverage_thresholds.yaml`) está en Global Constraints. La regla de ≥2, que el spec no tenía, entra en §4.3 y además queda verificada en la Task 3.

**Sin placeholders.** Cada step trae el contenido literal: pubspecs completos, el test entero, el texto del spec, los comandos con su salida esperada.

**Consistencia de tipos.** Los builders se mueven sin editarse (Task 1 Step 2), así que las firmas siguen siendo las de `origin/develop`: `aMoney({int amount, String currency, bool? taxIncluded})`, `aStock({int available, int? min, int? reserved, int? lowStockThreshold})`, `aProduct({String id, String sku, String name, ProductCategory category, Money? price, Stock? stock, OrderConstraints? orderConstraints, String? imageUrl, String? description})`. El test de la Task 1 Step 4 usa solo esos nombres. El nombre del package, `catalog_test_builders`, es el mismo en el pubspec (Task 1), en el swap de `cart` (Task 2), en el spec (Task 5) y en la verificación (Task 6).

**Riesgo conocido.** `melos bootstrap` corre cuatro veces (Tasks 1, 2, 3, 4) y tarda unos minutos cada vez. Es a propósito: cada tarea cierra con su suite en verde. Quien ejecute puede saltear el bootstrap de la Task 4 si viene de correr el de la Task 3 sin tocar ningún pubspec en el medio — pero la Task 4 **sí** toca uno, así que ahí hace falta.
