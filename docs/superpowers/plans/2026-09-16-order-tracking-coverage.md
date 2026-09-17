# Phase 2b — order_tracking coverage (#164) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring `order_tracking` from its measured 32.3% to the 80% floor spec §5 requires, and set that floor in `coverage_thresholds.yaml`.

**Architecture:** The package already has a partial suite (36 tests) covering the mapper, both repositories and two cubits. This plan does not restart it — it fills the measured gap layer by layer per spec §4.1, migrates the two existing cubit tests off the fragile `stream.listen` + `Future.delayed` pattern that spec §4.2 replaced with `blocTest`, and removes the hand-rolled `_FakeCatalog` duplication that spec §4.3 calls out by name.

**Tech Stack:** Dart SDK `>=3.8.0 <4.0.0`, Flutter 3.44.0, melos 7.8.0, `mocktail`, `bloc_test`, `dartz` (`Either`), `web_socket_channel`, lcov coverage gate.

**Spec:** `docs/superpowers/specs/2026-08-12-test-strategy-design.md`

**Issue:** #164 (E8.2.10), part of epic #129.

---

## The measured gap

Measured on 2026-09-16 with the repo's own tooling (`dart run tool/gen_coverage_imports.dart`, then `flutter test --coverage`), applying the exclusions from `coverage_thresholds.yaml` (`**/*.g.dart`, `**/*.freezed.dart`, `**/presentation/pages/**`):

```
TOTAL: 166/514 = 32.3%   (floor actual 32, target 80)
Faltan 245 líneas cubiertas para llegar a 80%
```

| % | hit/found | archivo | Tarea |
|---:|---:|---|---|
| 1.4 | 1/74 | `presentation/widgets/order_status_timeline.dart` | 7 |
| 0.0 | 0/60 | `order_tracking_feature_builder.dart` | 10 |
| 37.9 | 39/103 | `data/repositories/remote_order_tracking_repository.dart` | 11 (parcial) |
| 43.1 | 28/65 | `presentation/bloc/order_list_cubit.dart` | 6 |
| 0.0 | 0/37 | `presentation/widgets/order_card.dart` | 8 |
| 0.0 | 0/26 | `presentation/bloc/order_notification_cubit.dart` | 5 |
| 5.0 | 1/20 | `presentation/widgets/notification_bell.dart` | 9 |
| 0.0 | 0/9 | `domain/entities/order_item_detail.dart` | 3 |
| 0.0 | 0/6 | `domain/entities/order_notification.dart` | 4 |
| 82.1 | 23/28 | `data/repositories/mock_order_tracking_repository.dart` | 12 |
| 86.1 | 31/36 | `presentation/bloc/order_detail_cubit.dart` | 12 |
| 95.8 | 23/24 | `data/mappers/order_tracking_mapper.dart` | 12 |
| 50.0 | 1/2 | `presentation/bloc/order_notification_state.dart` | 4 |
| 0.0 | 0/1 | `domain/entities/order_status_change.dart` | 3 |
| 0.0 | 0/2 | `data/dtos/order_timestamps_dto.dart` | 12 |
| 0.0 | 0/2 | `data/dtos/order_tracking_line_item_dto.dart` | 12 |

Everything else already measures 100%.

**Re-measure before trusting this table.** It was taken on the branch this plan builds on, before any task ran. If it has drifted, regenerate it (Task 0, Step 3) rather than planning against stale numbers.

## What this plan deliberately does NOT test

**The two WebSocket retry loops in `RemoteOrderTrackingRepository`** — `_connectWithRetry` and `_watchStatusChangesLoop`, roughly 45 of that file's 64 uncovered lines.

Both are `while (!controller.isClosed)` loops that call the real `WebSocketChannel.connect` and the real `Future.delayed(Duration(seconds: delay))` with a backoff reaching 30 seconds. There is no seam to inject a fake channel: the constructor takes `httpHelper`, `getToken`, `baseUrl` and `historyStore`, and builds the channel inline. Testing them honestly means either adding a channel-factory parameter to production code — a refactor this issue did not ask for — or driving them with `fake_async`, which the repo uses nowhere today.

**We do not need them.** Covering every other gap in the table yields roughly 469/514 ≈ 91%, comfortably past 80%, and the minimum required is 245 of the 348 uncovered lines.

If a later task finds the floor unreachable without them, **stop and report** — do not add an exclusion. Per spec §5.1, exclusions are legitimate only for thin platform adapters that delegate to a plugin, and a retry loop carrying business logic is not one.

## Global Constraints

- Dart SDK constraint for all packages: `'>=3.8.0 <4.0.0'`
- Target (spec §5): `order_tracking` 80
- Coverage floors only ever increase. **Never set a floor above the measured value.**
- Coverage denominator always excludes `**/*.g.dart`, `**/*.freezed.dart` and `**/presentation/pages/**`
- Pages are **not** tested here (spec §4.1) — that layer is Patrol's (#131). `order_list_page.dart`, `order_detail_page.dart` and `notifications_page.dart` are out of scope and already out of the denominator.
- Widgets are tested **selectively**: only those carrying logic — state, callbacks, conditional rendering. Never assert on padding, radius or hex colors.
- `mocktail` + `bloc_test` are the standard (spec §4.2). Hand-written fakes only where a stateful fake is genuinely clearer than a mock.
- Commit messages: `type(scope): subject`, lowercase, Spanish subject
- Never `git add -A` — the working tree carries `pubspec.lock` churn from every `melos bootstrap`
- Run everything from the repo root; each shell invocation is fresh, so never rely on a previous `cd`

## Environment

The repo path contains a space. **Always quote it.**

- Repo root: `"C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse"`
- `flutter` is at `/c/Users/Bauta/flutter/flutter/bin/flutter` (Flutter 3.44.0), already on `PATH`
- `melos` is **not** on `PATH` non-interactively. Invoke it by full path: `"$HOME/AppData/Local/Pub/Cache/bin/melos.bat"`
- Run one package's tests: `cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub`
- `melos bootstrap` must run after any `pubspec.yaml` change, before the next `flutter test`
- **Do not commit `pubspec.lock` files.** The local Flutter 3.44.0 is older than the one that generated the committed locks; bootstrap rewrites them with downgrades of unrelated transitives (`matcher` 0.12.20→0.12.19, `meta` 1.19.0→1.18.0). Stage `pubspec.yaml` and `pubspec_overrides.yaml` explicitly and leave the locks dirty.
- Writing large files with a bash heredoc has failed in this environment. Use the editor tooling to create test files.

## Branching

This plan **depends on commit `f8ccf2b`** (`test(orders): agregar orders_test_builders…`), which is local and unpushed on `feature/e8.2-phase2b-orders-builders`. That commit creates `packages/orders_test_builders` (`anOrder`, `anOrderItem`, `anOrderDestination`) and wires it into `order_tracking`'s dev dependencies. Branch from there, not from `develop`.

## Coordination note

#163 (`orders` to 80%) is assigned to another developer and is still open. This plan touches **nothing** inside `packages/features/orders/test/` and does not move the `orders` floor. It does add a shared fake to `catalog_test_builders` (Task 1) that #163 may also want — tell them rather than letting both branches add one.

---

## File Structure

**Created:**
- `packages/catalog_test_builders/lib/src/fakes/fake_catalog_repository.dart` — `FakeCatalogRepository`, replacing the duplicated `_FakeCatalog`
- `packages/catalog_test_builders/test/fake_catalog_repository_test.dart`
- `packages/features/order_tracking/test/support/fake_order_tracking_repository.dart` — `FakeOrderTrackingRepository`, used by four test files in this package
- `packages/features/order_tracking/test/domain/entities/order_item_detail_test.dart`
- `packages/features/order_tracking/test/domain/entities/order_notification_test.dart`
- `packages/features/order_tracking/test/presentation/bloc/order_notification_cubit_test.dart`
- `packages/features/order_tracking/test/presentation/widgets/order_status_timeline_test.dart`
- `packages/features/order_tracking/test/presentation/widgets/order_card_test.dart`
- `packages/features/order_tracking/test/presentation/widgets/notification_bell_test.dart`
- `packages/features/order_tracking/test/order_tracking_feature_builder_test.dart`

**Modified:**
- `packages/catalog_test_builders/lib/catalog_test_builders.dart` — export the fake
- `packages/catalog_test_builders/pubspec.yaml` — add `dartz`
- `packages/features/order_tracking/pubspec.yaml` — add `catalog_test_builders` and `test_support` dev dependencies
- `packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart` — migrate to `blocTest` + shared fakes + builders; add hydration cases
- `packages/features/order_tracking/test/presentation/bloc/order_detail_cubit_test.dart` — migrate to shared fakes and builders
- `packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart` — add reachable branches
- `packages/features/order_tracking/test/data/repositories/mock_order_tracking_repository_test.dart` — close the last 5 lines
- `packages/features/order_tracking/test/data/mappers/order_tracking_mapper_test.dart` — close the last line
- `coverage_thresholds.yaml` — raise the `order_tracking` floor

**Why the fakes live where they do.** `FakeCatalogRepository` is needed by `catalog`, `cart` and `order_tracking`, so by the ≥2-consumers rule of spec §4.3 it belongs in a shared package — and since `catalog_test_builders` already depends on `catalog`, it extends that package instead of creating a new one. Spec §4.3 names this duplication: *"`order_tracking` reimplementa a mano un `_FakeCatalog` que los tests de `catalog` ya definen, con los tres métodos no usados devolviendo `Left(CatalogFailure('not used'))`."* `FakeOrderTrackingRepository` is needed by four files inside one package only, so it stays in that package's `test/support/`.

---

## Task 0: Branch and baseline

**Files:** none

**Interfaces:**
- Consumes: commit `f8ccf2b` on `feature/e8.2-phase2b-orders-builders`
- Produces: a working branch and a verified baseline number

- [ ] **Step 1: Cut the branch**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git checkout feature/e8.2-phase2b-orders-builders && git checkout -b feature/e8.2-order-tracking-coverage && git log --oneline -1
```
Expected: `f8ccf2b test(orders): agregar orders_test_builders para desbloquear order_tracking`

- [ ] **Step 2: Bootstrap**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" bootstrap
```
Expected: `15 packages bootstrapped`.

- [ ] **Step 3: Re-measure the baseline**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/gen_coverage_imports.dart && cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub --coverage
```
Expected: 36 tests pass, `coverage/lcov.info` written.

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/check_coverage.dart
```
Read `order_tracking`'s row. Expected: about 32%. If it differs materially from the table above, re-derive the per-file gap before continuing — the task ordering is driven by those numbers.

---

## Task 1: Shared FakeCatalogRepository in catalog_test_builders

**Files:**
- Modify: `packages/catalog_test_builders/pubspec.yaml`
- Create: `packages/catalog_test_builders/lib/src/fakes/fake_catalog_repository.dart`
- Modify: `packages/catalog_test_builders/lib/catalog_test_builders.dart`
- Create: `packages/catalog_test_builders/test/fake_catalog_repository_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produces: `FakeCatalogRepository`, with mutable fields `onGetProductById` (`Either<CatalogFailure, Product> Function(String id)`), `onGetProducts` (`Either<CatalogFailure, ProductsPage> Function()`), `onGetCategories` (`Either<CatalogFailure, List<ProductCategory>> Function()`), and the read-only `List<String> requestedIds`. Consumed by Tasks 6, 10 and 12.

- [ ] **Step 1: Read the real interface first**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart
```
Match the signatures below against what you read. If they differ, the real interface wins — implement that one.

- [ ] **Step 2: Add the dartz dependency**

`CatalogRepository`'s methods return `Either`, so the package needs `dartz` to implement the interface. In `packages/catalog_test_builders/pubspec.yaml`, under `dependencies:`, after the `catalog:` block:

```yaml
  dartz: ^0.10.1
```

- [ ] **Step 3: Write the failing test**

Create `packages/catalog_test_builders/test/fake_catalog_repository_test.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeCatalogRepository', () {
    test('falla por defecto, para que un test que no lo configura no pase por accidente', () async {
      final fake = FakeCatalogRepository();

      expect((await fake.getProductById('p-1')).isLeft(), isTrue);
      expect((await fake.getProducts()).isLeft(), isTrue);
      expect((await fake.getCategories()).isLeft(), isTrue);
    });

    test('devuelve el producto que le configuran', () async {
      final fake = FakeCatalogRepository()
        ..onGetProductById = (id) => Right(aProduct(id: id));

      final result = await fake.getProductById('p-7');

      expect(result.getOrElse(() => aProduct()).id, 'p-7');
    });

    test('registra los ids pedidos, en orden', () async {
      final fake = FakeCatalogRepository();

      await fake.getProductById('p-1');
      await fake.getProductById('p-2');

      expect(fake.requestedIds, ['p-1', 'p-2']);
    });
  });
}
```

- [ ] **Step 4: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" bootstrap && cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/catalog_test_builders" && flutter test --no-pub
```
Expected: FAIL with `Method not found: 'FakeCatalogRepository'`.

- [ ] **Step 5: Write the fake**

Create `packages/catalog_test_builders/lib/src/fakes/fake_catalog_repository.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart';

/// Stand-in de [CatalogRepository] para tests de otros packages.
///
/// Reemplaza los `_FakeCatalog` duplicados a mano que el spec 4.3 marca por
/// nombre. Cada metodo delega en un callback reasignable, asi un test
/// configura solo lo que le importa.
///
/// Los defaults fallan a proposito: un test que consume el catalogo sin
/// configurarlo se esta apoyando en un valor que nadie eligio.
class FakeCatalogRepository implements CatalogRepository {
  Either<CatalogFailure, Product> Function(String id) onGetProductById =
      (_) => const Left(CatalogFailure('not configured'));

  Either<CatalogFailure, ProductsPage> Function() onGetProducts =
      () => const Left(CatalogFailure('not configured'));

  Either<CatalogFailure, List<ProductCategory>> Function() onGetCategories =
      () => const Left(CatalogFailure('not configured'));

  /// Ids pedidos a [getProductById], en orden. Sirve para afirmar que un
  /// cache evito un segundo fetch sin tener que mockear.
  final List<String> requestedIds = [];

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    requestedIds.add(id);
    return onGetProductById(id);
  }

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) async =>
      onGetProducts();

  @override
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() async =>
      onGetCategories();
}
```

- [ ] **Step 6: Export it**

Rewrite `packages/catalog_test_builders/lib/catalog_test_builders.dart`:

```dart
library catalog_test_builders;

export 'src/builders/money_builder.dart';
export 'src/builders/product_builder.dart';
export 'src/builders/stock_builder.dart';
export 'src/fakes/fake_catalog_repository.dart';
```

- [ ] **Step 7: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/catalog_test_builders" && flutter test --no-pub
```
Expected: PASS, including the pre-existing `builders_test.dart`.

- [ ] **Step 8: Verify it analyzes**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/catalog_test_builders" && flutter analyze
```
Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/catalog_test_builders/lib packages/catalog_test_builders/test packages/catalog_test_builders/pubspec.yaml && git commit -m "test(catalog): agregar FakeCatalogRepository compartido"
```

---

## Task 2: order_tracking test support and dependency wiring

The package's two cubit tests each hand-roll a `_FakeRepo implements OrderTrackingRepository`. Four test files will need one by the end of this plan, so it goes in `test/support/` — one package, so not shared (spec §4.3).

**Files:**
- Modify: `packages/features/order_tracking/pubspec.yaml`
- Create: `packages/features/order_tracking/test/support/fake_order_tracking_repository.dart`

**Interfaces:**
- Consumes: `FakeCatalogRepository` (Task 1); `anOrder`, `anOrderItem` from `orders_test_builders` (commit `f8ccf2b`)
- Produces: `FakeOrderTrackingRepository` with mutable fields `onGetOrders` (`Either<OrderTrackingFailure, List<Order>> Function()`), `onGetOrderById` (`Either<OrderTrackingFailure, Order> Function(String id)`), the broadcast controllers `orderController` (`StreamController<Order>`) and `statusChangeController` (`StreamController<OrderStatusChange>`), the counter `int getOrdersCalls`, and `Future<void> dispose()`. Consumed by Tasks 5, 6, 9, 10 and 12.

- [ ] **Step 1: Add the dev dependencies**

In `packages/features/order_tracking/pubspec.yaml`, under `dev_dependencies:`, after the `orders_test_builders:` block added by `f8ccf2b`:

```yaml
  catalog_test_builders:
    path: ../../catalog_test_builders
  test_support:
    path: ../../test_support
```

`catalog_test_builders` is needed from Task 6 on; `test_support` supplies `resetInjector()` and `registerMock<T>()` for Tasks 9 and 10.

- [ ] **Step 2: Bootstrap so they resolve**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" bootstrap
```
Expected: `15 packages bootstrapped`.

- [ ] **Step 3: Write the fake**

Create `packages/features/order_tracking/test/support/fake_order_tracking_repository.dart`:

```dart
import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

/// Stand-in configurable de [OrderTrackingRepository].
///
/// Es un fake con estado y no un mock de mocktail a proposito: dos de los
/// cuatro metodos devuelven `Stream`, y un test que necesita empujar eventos
/// de a uno se lee mejor con un controller expuesto que con un `when()` que
/// devuelve un stream prefabricado.
///
/// Vive en `test/support/` y no en un package compartido porque lo consume un
/// solo package (spec 4.3): la regla de >=2 cuenta packages, no archivos.
class FakeOrderTrackingRepository implements OrderTrackingRepository {
  Either<OrderTrackingFailure, List<Order>> Function() onGetOrders =
      () => const Right([]);

  Either<OrderTrackingFailure, Order> Function(String id) onGetOrderById =
      (_) => const Left(OrderTrackingFailure('not configured'));

  /// Alimenta [watchOrder]. Broadcast para que un test pueda escuchar dos
  /// veces sin que la segunda suscripcion tire.
  final orderController = StreamController<Order>.broadcast();

  /// Alimenta [watchOrderStatusChanges].
  final statusChangeController = StreamController<OrderStatusChange>.broadcast();

  /// Cuantas veces se llamo a [getOrders]. Sirve para afirmar que un refresh
  /// silencioso efectivamente re-consulto.
  int getOrdersCalls = 0;

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    getOrdersCalls++;
    return onGetOrders();
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      onGetOrderById(id);

  @override
  Stream<Order> watchOrder(String id) => orderController.stream;

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() =>
      statusChangeController.stream;

  Future<void> dispose() async {
    await orderController.close();
    await statusChangeController.close();
  }
}
```

- [ ] **Step 4: Verify it analyzes**

There is no test for this file yet — Task 5 is its first consumer. Confirm it compiles:

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter analyze
```
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/pubspec.yaml packages/features/order_tracking/pubspec_overrides.yaml packages/features/order_tracking/test/support && git commit -m "test(order_tracking): agregar fake compartido del repo y cablear builders"
```

---

## Task 3: OrderItemDetail getters

`OrderItemDetail` is the fallback chain between the hydrated `Product` and the raw `OrderItem`. Nine uncovered lines, all hand-written logic — exactly what spec §4.1 says to test on an entity.

**Files:**
- Create: `packages/features/order_tracking/test/domain/entities/order_item_detail_test.dart`

**Interfaces:**
- Consumes: `anOrderItem` (from `orders_test_builders`), `aMoney`/`aProduct` (from `catalog_test_builders`)
- Produces: nothing later tasks depend on

- [ ] **Step 1: Write the failing test**

Create `packages/features/order_tracking/test/domain/entities/order_item_detail_test.dart`:

```dart
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

void main() {
  group('OrderItemDetail.name', () {
    test('prefiere el nombre del producto hidratado', () {
      final detail = OrderItemDetail(
        item: anOrderItem(productName: 'del back'),
        product: aProduct(name: 'del catalogo'),
      );

      expect(detail.name, 'del catalogo');
    });

    test('cae al nombre del item cuando no hay producto', () {
      final detail = OrderItemDetail(item: anOrderItem(productName: 'del back'));

      expect(detail.name, 'del back');
    });

    test('cae al productId cuando no hay producto ni nombre', () {
      final detail = OrderItemDetail(
        item: anOrderItem(productId: 'p-42', productName: ''),
      );

      expect(detail.name, 'p-42');
    });
  });

  group('OrderItemDetail.unitPrice y subtotal', () {
    test('usa el precio del catalogo cuando hay producto', () {
      final detail = OrderItemDetail(
        item: anOrderItem(quantity: 3, unitPrice: aMoney(amount: 100)),
        product: aProduct(price: aMoney(amount: 250)),
      );

      expect(detail.unitPrice.amount, 250);
      expect(detail.subtotal.amount, 750);
    });

    test('cae al precio del item cuando el fetch de catalogo fallo', () {
      final detail = OrderItemDetail(
        item: anOrderItem(quantity: 2, unitPrice: aMoney(amount: 100)),
      );

      expect(detail.unitPrice.amount, 100);
      expect(detail.subtotal.amount, 200);
    });
  });

  group('OrderItemDetail.imageUrl', () {
    test('es null sin producto, porque el OrderItem no trae imagen', () {
      expect(OrderItemDetail(item: anOrderItem()).imageUrl, isNull);
    });
  });

  group('OrderStatusChange', () {
    test('conserva el estado viejo y el nuevo', () {
      const change = OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      );

      expect(change.orderId, 'o-1');
      expect(change.oldStatus, OrderStatus.pending);
      expect(change.newStatus, OrderStatus.inProgress);
    });
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/domain/entities/order_item_detail_test.dart
```
Expected: FAIL. If `aProduct` does not accept `name:` or `price:`, read `packages/catalog_test_builders/lib/src/builders/product_builder.dart` and use its real parameter names — do not change the builder.

- [ ] **Step 3: No implementation needed**

These entities already exist and are correct. This task only adds coverage. Once the parameter names match, the test should pass.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/domain/entities/order_item_detail_test.dart
```
Expected: PASS, 9 tests.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/domain && git commit -m "test(order_tracking): cubrir el fallback de OrderItemDetail"
```

---

## Task 4: OrderNotification and its state

**Files:**
- Create: `packages/features/order_tracking/test/domain/entities/order_notification_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produces: nothing later tasks depend on

- [ ] **Step 1: Write the failing test**

Create `packages/features/order_tracking/test/domain/entities/order_notification_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_notification.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';
import 'package:orders/orders.dart';

OrderNotification _notification({required String id, bool read = false}) =>
    OrderNotification(
      id: id,
      change: const OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      ),
      receivedAt: DateTime.utc(2026, 1, 1),
      read: read,
    );

void main() {
  group('OrderNotification.copyWith', () {
    test('cambia read y conserva todo lo demas', () {
      final original = _notification(id: 'n-1');

      final marked = original.copyWith(read: true);

      expect(marked.read, isTrue);
      expect(marked.id, 'n-1');
      expect(marked.change.orderId, 'o-1');
      expect(marked.receivedAt, original.receivedAt);
    });

    test('sin argumentos deja read como estaba', () {
      expect(_notification(id: 'n-1', read: true).copyWith().read, isTrue);
    });
  });

  group('OrderNotificationState.unreadCount', () {
    test('cuenta solo las no leidas', () {
      final state = OrderNotificationState(
        notifications: [
          _notification(id: 'n-1'),
          _notification(id: 'n-2', read: true),
          _notification(id: 'n-3'),
        ],
      );

      expect(state.unreadCount, 2);
    });

    test('es cero cuando no hay notificaciones', () {
      expect(const OrderNotificationState().unreadCount, 0);
    });
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/domain/entities/order_notification_test.dart
```
Expected: FAIL only if something is genuinely wrong. These are existing, correct entities — the test should compile and pass once imports resolve. If it passes on the first run, that is expected for a coverage-filling task on already-written code; confirm it is running (the output must show 4 tests, not 0).

- [ ] **Step 3: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/domain/entities/order_notification_test.dart
```
Expected: PASS, 4 tests.

- [ ] **Step 4: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/domain && git commit -m "test(order_tracking): cubrir OrderNotification y unreadCount"
```

---

## Task 5: OrderNotificationCubit

26 uncovered lines. This cubit builds a notification id from `DateTime.now()`, prepends to the list, fires an optional callback, and has two mark-as-read paths.

**Files:**
- Create: `packages/features/order_tracking/test/presentation/bloc/order_notification_cubit_test.dart`

**Interfaces:**
- Consumes: `FakeOrderTrackingRepository` (Task 2)
- Produces: nothing later tasks depend on

- [ ] **Step 1: Write the failing test**

Create `packages/features/order_tracking/test/presentation/bloc/order_notification_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';
import 'package:orders/orders.dart';

import '../../support/fake_order_tracking_repository.dart';

const _change = OrderStatusChange(
  orderId: 'o-1',
  oldStatus: OrderStatus.pending,
  newStatus: OrderStatus.inProgress,
);

const _otherChange = OrderStatusChange(
  orderId: 'o-2',
  oldStatus: OrderStatus.inProgress,
  newStatus: OrderStatus.completed,
);

void main() {
  late FakeOrderTrackingRepository repo;

  setUp(() => repo = FakeOrderTrackingRepository());
  tearDown(() => repo.dispose());

  test('arranca vacio y no escucha hasta que se llama start', () {
    final cubit = OrderNotificationCubit(repo);

    expect(cubit.state.notifications, isEmpty);
    expect(cubit.state.lastReceived, isNull);

    cubit.close();
  });

  test('emite una notificacion por cada cambio del WS', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.notifications, hasLength(1));
    expect(cubit.state.notifications.single.change.orderId, 'o-1');
    expect(cubit.state.lastReceived, isNotNull);

    await cubit.close();
  });

  test('pone la mas nueva primero', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state.notifications.map((n) => n.change.orderId),
      ['o-2', 'o-1'],
    );

    await cubit.close();
  });

  test('invoca onEvent con el cambio recibido', () async {
    final seen = <OrderStatusChange>[];
    final cubit = OrderNotificationCubit(repo, onEvent: seen.add)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [_change]);

    await cubit.close();
  });

  test('markAllAsRead deja unreadCount en cero', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    cubit.markAllAsRead();

    expect(cubit.state.unreadCount, 0);

    await cubit.close();
  });

  test('markAsRead marca solo la que coincide por id', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    final target = cubit.state.notifications.last;
    cubit.markAsRead(target.id);

    expect(cubit.state.unreadCount, 1);
    expect(
      cubit.state.notifications.firstWhere((n) => n.id == target.id).read,
      isTrue,
    );

    await cubit.close();
  });

  test('markAllAsRead limpia lastReceived para no re-disparar la SnackBar', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    cubit.markAllAsRead();

    expect(cubit.state.lastReceived, isNull);

    await cubit.close();
  });

  test('un error del WS no rompe el cubit', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.addError(Exception('ws caido'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.isClosed, isFalse);
    expect(cubit.state.notifications, isEmpty);

    await cubit.close();
  });

  test('start dos veces no duplica las notificaciones', () async {
    final cubit = OrderNotificationCubit(repo)
      ..start()
      ..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.notifications, hasLength(1));

    await cubit.close();
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/bloc/order_notification_cubit_test.dart
```
Expected: FAIL. Two of these assert behavior the current code may not have:

- *"markAllAsRead limpia lastReceived"* — `markAllAsRead` emits `OrderNotificationState(notifications: updated)` without `lastReceived`, so it already clears. Confirm rather than assume.
- *"start dos veces no duplica"* — `start()` cancels the previous subscription first, so this should hold. If it fails, the bug is real: report it, do not weaken the test.

- [ ] **Step 3: Fix only what the tests prove broken**

Do **not** edit production code to make a test pass unless the test describes correct behavior and the code genuinely violates it. If one of the two above fails, stop and report which, with the failure output — a behavior change in a cubit that drives user-visible SnackBars is not a call to make silently inside a coverage task.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/bloc/order_notification_cubit_test.dart
```
Expected: PASS, 9 tests.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/presentation/bloc/order_notification_cubit_test.dart && git commit -m "test(order_tracking): cubrir OrderNotificationCubit"
```

---

## Task 6: OrderListCubit — hydration, price application and migration to blocTest

37 uncovered lines, nearly all in `_hydrate` and `_applyPrices`. This task also replaces the file's hand-rolled `_FakeCatalog`/`_FakeRepo` and the `stream.listen` + `Future.delayed(Duration.zero)` pattern that spec §4.2 calls fragile.

**Files:**
- Modify: `packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart`

**Interfaces:**
- Consumes: `FakeOrderTrackingRepository` (Task 2), `FakeCatalogRepository` (Task 1), `anOrder`/`anOrderItem`/`aMoney`/`aProduct`
- Produces: nothing later tasks depend on

- [ ] **Step 1: Read what is there now**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart
```
Four tests exist: initial state, Loading→Ready, Loading→Error, and refresh. Keep all four behaviors; only their mechanics change.

- [ ] **Step 2: Rewrite the file**

`OrderListCubit` kicks off `load()` from its constructor via `scheduleMicrotask`, so `blocTest`'s `build` already triggers the first emission. Replace the whole file with:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

import '../../support/fake_order_tracking_repository.dart';

void main() {
  late FakeOrderTrackingRepository repo;
  late FakeCatalogRepository catalog;

  setUp(() {
    repo = FakeOrderTrackingRepository();
    catalog = FakeCatalogRepository();
  });

  tearDown(() => repo.dispose());

  OrderListCubit build() => OrderListCubit(repo, catalog);

  test('el estado inicial es OrderListLoading', () {
    final cubit = build();

    expect(cubit.state, isA<OrderListLoading>());

    cubit.close();
  });

  blocTest<OrderListCubit, OrderListState>(
    'emite Ready con las ordenes que devuelve el repo',
    setUp: () => repo.onGetOrders = () => Right([anOrder(id: 'o-1', items: [])]),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<OrderListReady>().having((s) => s.orders.single.id, 'id', 'o-1'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'emite Error con el mensaje del failure',
    setUp: () => repo.onGetOrders =
        () => const Left(OrderTrackingFailure('sin conexion')),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<OrderListError>().having((s) => s.message, 'message', 'sin conexion'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'un failure sin mensaje cae a un texto generico',
    setUp: () => repo.onGetOrders = () => const Left(OrderTrackingFailure()),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<OrderListError>()
          .having((s) => s.message, 'message', 'Error desconocido'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'refresh vuelve a pasar por Loading',
    setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
    build: build,
    wait: const Duration(milliseconds: 10),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<OrderListReady>(),
      isA<OrderListLoading>(),
      isA<OrderListReady>(),
    ],
  );

  group('hidratacion de precios', () {
    blocTest<OrderListCubit, OrderListState>(
      'reemplaza unitPrice y calcula el total con los precios del catalogo',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 2),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => Right(
              aProduct(id: id, price: aMoney(amount: id == 'p-1' ? 500 : 300)),
            );
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 1300),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'deja el total en cero si algun producto no se pudo hidratar',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 2),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => id == 'p-1'
            ? Right(aProduct(id: id, price: aMoney(amount: 500)))
            : const Left(CatalogFailure('404'));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 0),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'deja el total en cero si los items mezclan monedas',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 1),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => Right(
              aProduct(
                id: id,
                price: aMoney(
                  amount: 500,
                  currency: id == 'p-1' ? 'ARS' : 'USD',
                ),
              ),
            );
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 0),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'reemplaza el placeholder del mapper por el nombre real del catalogo',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(
                    productId: 'p-1',
                    productName: 'Producto no disponible',
                  ),
                ],
              ),
            ]);
        catalog.onGetProductById =
            (id) => Right(aProduct(id: id, name: 'Taladro'));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListReady>().having(
          (s) => s.orders.single.items.single.productName,
          'productName',
          'Taladro',
        ),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'una orden sin items no dispara ningun fetch de catalogo',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      verify: (_) => expect(catalog.requestedIds, isEmpty),
      expect: () => [isA<OrderListReady>()],
    );

    blocTest<OrderListCubit, OrderListState>(
      'no re-fetchea un producto que ya esta en el cache',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(id: 'o-1', items: [anOrderItem(productId: 'p-1')]),
              anOrder(id: 'o-2', items: [anOrderItem(productId: 'p-1')]),
            ]);
        catalog.onGetProductById =
            (id) => Right(aProduct(id: id, price: aMoney(amount: 500)));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (cubit) => cubit.refresh(),
      verify: (_) => expect(catalog.requestedIds, ['p-1']),
      expect: () => [
        isA<OrderListReady>(),
        isA<OrderListLoading>(),
        isA<OrderListReady>(),
      ],
    );
  });

  group('refresh silencioso', () {
    blocTest<OrderListCubit, OrderListState>(
      'un cambio de estado por WS re-consulta sin pasar por Loading',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (_) async {
        repo.statusChangeController.add(const OrderStatusChange(
          orderId: 'o-1',
          oldStatus: OrderStatus.pending,
          newStatus: OrderStatus.inProgress,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      expect: () => [isA<OrderListReady>(), isA<OrderListReady>()],
    );

    blocTest<OrderListCubit, OrderListState>(
      'silentRefresh desde Loading hace un load completo',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: () => OrderListCubit(repo, catalog),
      act: (cubit) => cubit.silentRefresh(),
      wait: const Duration(milliseconds: 10),
      verify: (_) => expect(repo.getOrdersCalls, greaterThanOrEqualTo(1)),
    );

    blocTest<OrderListCubit, OrderListState>(
      'un failure en el refresh silencioso no pisa el Ready que ya se mostraba',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (cubit) async {
        repo.onGetOrders = () => const Left(OrderTrackingFailure('caido'));
        await cubit.silentRefresh();
      },
      expect: () => [isA<OrderListReady>()],
    );
  });

  test('close cancela la suscripcion al WS', () async {
    final cubit = build();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await cubit.close();
    repo.statusChangeController.add(const OrderStatusChange(
      orderId: 'o-1',
      oldStatus: OrderStatus.pending,
      newStatus: OrderStatus.completed,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.isClosed, isTrue);
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/bloc/order_list_cubit_test.dart
```
Expected: FAIL on the hydration cases first — they exercise `_applyPrices`, which nothing covered before.

**Tuning note.** `OrderListCubit` chains several `await`s per emission (`getOrders`, then `Future.wait` over the catalog). If a `blocTest` sees fewer states than expected, raise `wait` before doubting the assertion. Do not replace `wait` with a bare `Future.delayed` in `act` — that is the pattern this task exists to remove.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/bloc/order_list_cubit_test.dart
```
Expected: PASS, 15 tests.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/presentation/bloc/order_list_cubit_test.dart && git commit -m "test(order_tracking): migrar OrderListCubit a blocTest y cubrir la hidratacion"
```

---

## Task 7: OrderStatusTimeline widget

74 lines, 73 uncovered — the single biggest win in the package. It is a widget with real logic: `_currentStep` maps status to an index, each node resolves to done/current/todo, and `cancelled` short-circuits to a different subtree. Spec §4.1 puts this squarely in "widgets **with logic**".

**Files:**
- Create: `packages/features/order_tracking/test/presentation/widgets/order_status_timeline_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produces: nothing later tasks depend on

- [ ] **Step 1: Read the widget before asserting on it**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/features/order_tracking/lib/src/presentation/widgets/order_status_timeline.dart
```
Note the private classes `_CancelledBanner`, `_StepBubble`, `_StepRow` and the `_NodeState` enum. They are private, so a test cannot name their types. Assert on rendered text and on the public behavior instead — and **never** on colors, padding or radii (Global Constraints).

- [ ] **Step 2: Write the failing test**

Create `packages/features/order_tracking/test/presentation/widgets/order_status_timeline_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_timeline.dart';
import 'package:orders/orders.dart';

Future<void> _pump(WidgetTester tester, OrderStatus status) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderStatusTimeline(status: status),
        ),
      ),
    );

void main() {
  testWidgets('pending muestra los tres pasos del stepper', (tester) async {
    await _pump(tester, OrderStatus.pending);

    // Cada label aparece dos veces: en el bubble horizontal y en la lista
    // vertical. Afirmamos eso y no una sola ocurrencia, porque el widget
    // dibuja las dos representaciones a proposito.
    expect(find.text('Pendiente'), findsNWidgets(2));
    expect(find.text('En progreso'), findsNWidgets(2));
    expect(find.text('Completado'), findsNWidgets(2));
  });

  testWidgets('inProgress renderiza sin romperse y mantiene los tres pasos',
      (tester) async {
    await _pump(tester, OrderStatus.inProgress);

    expect(find.text('En progreso'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed renderiza los tres pasos', (tester) async {
    await _pump(tester, OrderStatus.completed);

    expect(find.text('Completado'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled reemplaza el stepper por el banner', (tester) async {
    await _pump(tester, OrderStatus.cancelled);

    // El camino de cancelada es un subtree distinto: no hay stepper.
    expect(find.text('Pendiente'), findsNothing);
    expect(find.text('En progreso'), findsNothing);
    expect(find.text('Completado'), findsNothing);
  });

  testWidgets('cancelled no deja el arbol en estado de error', (tester) async {
    await _pump(tester, OrderStatus.cancelled);

    expect(tester.takeException(), isNull);
  });

  testWidgets('los cuatro estados renderizan numeros de paso 1 a 3',
      (tester) async {
    for (final status in [
      OrderStatus.pending,
      OrderStatus.inProgress,
      OrderStatus.completed,
    ]) {
      await _pump(tester, status);

      expect(find.text('1'), findsWidgets, reason: 'estado $status');
      expect(tester.takeException(), isNull, reason: 'estado $status');
    }
  });

  testWidgets('cambiar el status re-renderiza sin errores', (tester) async {
    await _pump(tester, OrderStatus.pending);
    await _pump(tester, OrderStatus.completed);
    await _pump(tester, OrderStatus.cancelled);

    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/order_status_timeline_test.dart
```
Expected: FAIL — the file does not exist yet, so the first run is about making it compile.

Two things commonly need adjusting once it compiles:

- **The `findsNWidgets(2)` counts.** Read the `build` method again: the labels render in both the horizontal bubbles and the vertical rows. If a step bubble renders its label differently, fix the expectation to match what the widget actually does — do not change the widget.
- **`_CancelledBanner`'s text.** The assertions above only check that the stepper labels are *absent*. If the banner has a stable user-facing string, add `expect(find.text('<ese texto>'), findsOneWidget);` to the cancelled test — a positive assertion is worth more than three negative ones.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/order_status_timeline_test.dart
```
Expected: PASS, 7 tests.

- [ ] **Step 5: Check the payoff**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/gen_coverage_imports.dart && cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub --coverage && cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/check_coverage.dart
```
`order_tracking` should have moved up by roughly 14 points from the baseline. If it barely moved, the widget is rendering a different subtree than the test assumes — investigate before continuing.

- [ ] **Step 6: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/presentation/widgets/order_status_timeline_test.dart && git commit -m "test(order_tracking): cubrir OrderStatusTimeline en sus cuatro estados"
```

---

## Task 8: OrderCard widget

37 uncovered lines. Three pieces of logic: `_formatDate` (Hoy / Ayer / dd/mm/yyyy), `_statusLabel` (four-way switch) and the `total.amount > 0 ? formatted : '—'` guard.

**Files:**
- Create: `packages/features/order_tracking/test/presentation/widgets/order_card_test.dart`

**Interfaces:**
- Consumes: `anOrder`, `anOrderItem`, `aMoney`
- Produces: nothing later tasks depend on

- [ ] **Step 1: Write the failing test**

Create `packages/features/order_tracking/test/presentation/widgets/order_card_test.dart`:

```dart
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/presentation/widgets/order_card.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

Future<void> _pump(
  WidgetTester tester,
  Order order, {
  VoidCallback? onTap,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCard(order: order, onTap: onTap ?? () {}),
        ),
      ),
    );

void main() {
  testWidgets('muestra el id de la orden', (tester) async {
    await _pump(tester, anOrder(id: 'WH-49281'));

    expect(find.text('WH-49281'), findsOneWidget);
  });

  testWidgets('dispara onTap al tocar la card', (tester) async {
    var tapped = 0;
    await _pump(tester, anOrder(), onTap: () => tapped++);

    await tester.tap(find.byType(OrderCard));
    await tester.pump();

    expect(tapped, 1);
  });

  group('formato de fecha', () {
    testWidgets('una orden de hoy dice "Hoy"', (tester) async {
      await _pump(tester, anOrder(createdAt: DateTime.now()));

      expect(find.textContaining('Hoy'), findsOneWidget);
    });

    testWidgets('una orden de ayer dice "Ayer"', (tester) async {
      await _pump(
        tester,
        anOrder(createdAt: DateTime.now().subtract(const Duration(days: 1))),
      );

      expect(find.textContaining('Ayer'), findsOneWidget);
    });

    testWidgets('una orden vieja muestra la fecha en d/m/aaaa', (tester) async {
      await _pump(tester, anOrder(createdAt: DateTime(2026, 3, 7)));

      expect(find.textContaining('7/3/2026'), findsOneWidget);
    });
  });

  group('etiqueta de estado', () {
    for (final (status, label) in const [
      (OrderStatus.pending, 'Pendiente'),
      (OrderStatus.inProgress, 'En progreso'),
      (OrderStatus.completed, 'Completado'),
      (OrderStatus.cancelled, 'Cancelado'),
    ]) {
      testWidgets('$status se muestra como "$label"', (tester) async {
        await _pump(tester, anOrder(status: status));

        expect(find.textContaining(label), findsOneWidget);
      });
    }
  });

  group('total', () {
    testWidgets('muestra el total formateado cuando es mayor a cero',
        (tester) async {
      await _pump(
        tester,
        anOrder(items: [], total: aMoney(amount: 4999900)),
      );

      expect(find.text(r'$49.999'), findsOneWidget);
    });

    testWidgets('muestra un guion cuando el total es cero, no un \$0 falso',
        (tester) async {
      await _pump(tester, anOrder(items: [], total: aMoney(amount: 0)));

      expect(find.text('—'), findsOneWidget);
      expect(find.text(r'$0'), findsNothing);
    });
  });

  testWidgets('muestra la cantidad de items', (tester) async {
    await _pump(
      tester,
      anOrder(items: [anOrderItem(), anOrderItem(productId: 'p-2')]),
    );

    expect(find.textContaining('2 items'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/order_card_test.dart
```
Expected: FAIL on compilation first.

**On the `$49.999` assertion:** `Money.formatted` drops the decimals when cents are 0 and groups thousands with `.`. 4999900 centavos is `$49.999`. Verify against `packages/features/catalog/lib/src/domain/entities/money.dart` rather than trusting this comment — if the format differs, fix the expectation.

- [ ] **Step 3: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/order_card_test.dart
```
Expected: PASS, 12 tests.

- [ ] **Step 4: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/presentation/widgets/order_card_test.dart && git commit -m "test(order_tracking): cubrir OrderCard — fecha, estado y total sin hidratar"
```

---

## Task 9: NotificationBell widget

20 lines, 19 uncovered. The logic is the badge: it renders only when `unreadCount > 0`, and caps the label at `9+`. The widget resolves its cubit and its navigation helper from the global `Injector`, so this is the first task that needs the `test_support` harness.

**Files:**
- Create: `packages/features/order_tracking/test/presentation/widgets/notification_bell_test.dart`

**Interfaces:**
- Consumes: `FakeOrderTrackingRepository` (Task 2), `resetInjector`/`registerMock` (from `test_support`)
- Produces: nothing later tasks depend on

- [ ] **Step 1: Find the NavigationHelper interface**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && grep -rn "abstract class NavigationHelper" -A 30 packages/commons/lib
```
`NotificationBell` resolves `NavigationHelper` on tap. Write a mocktail mock of it (`class _MockNavigationHelper extends Mock implements NavigationHelper {}`) and register it, or the tap test will throw on an unregistered type.

- [ ] **Step 2: Write the failing test**

Create `packages/features/order_tracking/test/presentation/widgets/notification_bell_test.dart`:

```dart
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_cubit.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';
import 'package:orders/orders.dart';
import 'package:test_support/test_support.dart';

import '../../support/fake_order_tracking_repository.dart';

class _MockNavigationHelper extends Mock implements NavigationHelper {}

OrderStatusChange _change(String orderId) => OrderStatusChange(
      orderId: orderId,
      oldStatus: OrderStatus.pending,
      newStatus: OrderStatus.inProgress,
    );

void main() {
  late FakeOrderTrackingRepository repo;
  late OrderNotificationCubit cubit;

  setUp(() async {
    await resetInjector();
    repo = FakeOrderTrackingRepository();
    cubit = OrderNotificationCubit(repo)..start();
    registerMock<OrderNotificationCubit>(cubit);
    registerMock<NavigationHelper>(_MockNavigationHelper());
  });

  tearDown(() async {
    await cubit.close();
    await repo.dispose();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NotificationBell())),
      );

  Future<void> push(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      repo.statusChangeController.add(_change('o-$i'));
      await tester.pump(Duration.zero);
    }
  }

  testWidgets('sin no-leidas no dibuja el badge', (tester) async {
    await pump(tester);

    expect(find.text('0'), findsNothing);
  });

  testWidgets('con una no-leida muestra el numero', (tester) async {
    await pump(tester);
    await push(tester, 1);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('con nueve no-leidas todavia muestra el numero exacto',
      (tester) async {
    await pump(tester);
    await push(tester, 9);
    await tester.pump();

    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('a partir de diez muestra 9+', (tester) async {
    await pump(tester);
    await push(tester, 10);
    await tester.pump();

    expect(find.text('9+'), findsOneWidget);
    expect(find.text('10'), findsNothing);
  });

  testWidgets('marcar todas como leidas esconde el badge', (tester) async {
    await pump(tester);
    await push(tester, 3);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    cubit.markAllAsRead();
    await tester.pump();

    expect(find.text('3'), findsNothing);
  });

  testWidgets('el tap navega a notificaciones', (tester) async {
    final nav = Injector.i.resolve<NavigationHelper>();
    await pump(tester);

    await tester.tap(find.byType(NotificationBell));
    await tester.pump();

    verify(() => nav.pushNamed(
          any(),
          routeName: any(named: 'routeName'),
          disableAnimation: any(named: 'disableAnimation'),
        )).called(1);
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/notification_bell_test.dart
```
Expected: FAIL.

Two likely adjustments:

- **`pushNamed`'s real signature.** The `verify` above guesses at named parameters. Match it to what Step 1 showed. `mocktail` needs `registerFallbackValue` for any non-primitive argument type matched with `any()`; if it complains, register a fallback in `setUpAll`.
- **The tap target.** `NotificationBell` wraps an `SwIconButton`. If tapping `NotificationBell` does not reach the button, tap `find.byType(SwIconButton)` instead and import `design_system`.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/presentation/widgets/notification_bell_test.dart
```
Expected: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/presentation/widgets/notification_bell_test.dart && git commit -m "test(order_tracking): cubrir el badge de NotificationBell"
```

---

## Task 10: OrderTrackingFeatureBuilder

60 lines, none covered. Three separable pieces: `injectDependencies` (which registrations happen, and the mock/remote branch), the small `build*` factories, and `_showOrderSnackBar` (the biggest chunk, driven through the global `scaffoldMessengerKey`).

Precedent: the phase2a plan established that feature builders **are** testable via `registerMock` from `test_support`, because their statics resolve from `Injector.i`.

**Files:**
- Create: `packages/features/order_tracking/test/order_tracking_feature_builder_test.dart`

**Interfaces:**
- Consumes: `resetInjector`/`registerMock`, `FakeOrderTrackingRepository`, `FakeCatalogRepository`
- Produces: nothing later tasks depend on

- [ ] **Step 1: Read what injectDependencies resolves**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/features/order_tracking/lib/src/order_tracking_feature_builder.dart
```
It resolves `AppDataSource`, `HttpHelper`, `OrderHistoryStore` and `CatalogRepository`. Every one of those must be registered before calling it, or it throws. Find `AppDataSource`'s shape first — the branch `isMock ? Mock… : Remote…` is the one worth covering:

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && grep -rn "class AppDataSource" -A 15 packages/core/lib packages/commons/lib
```

- [ ] **Step 2: Write the failing test**

Create `packages/features/order_tracking/test/order_tracking_feature_builder_test.dart`:

```dart
import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/order_tracking_feature_builder.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_cubit.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';
import 'package:orders/orders.dart';
import 'package:test_support/test_support.dart';

import 'support/fake_order_tracking_repository.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

class _MockNavigationHelper extends Mock implements NavigationHelper {}

class _FakeHistoryStore implements OrderHistoryStore {
  List<String> ids = const [];

  @override
  Future<List<String>> getOrderIds() async => ids;

  @override
  Future<void> addOrderId(String id) async => ids = [id, ...ids];

  @override
  Future<void> clear() async => ids = const [];
}

/// Registra todo lo que `injectDependencies` resuelve, menos el AppDataSource,
/// que cada test elige para ejercitar la rama mock o la remota.
void _registerCollaborators() {
  registerMock<HttpHelper>(_MockHttpHelper());
  registerMock<OrderHistoryStore>(_FakeHistoryStore());
  registerMock<CatalogRepository>(FakeCatalogRepository());
  registerMock<NavigationHelper>(_MockNavigationHelper());
}

void main() {
  setUp(resetInjector);

  group('injectDependencies', () {
    test('con AppDataSource mock registra el repositorio en memoria', () {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: true));

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(
        Injector.i.resolve<OrderTrackingRepository>(),
        isA<MockOrderTrackingRepository>(),
      );
    });

    test('con AppDataSource real registra el repositorio remoto', () {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: false));

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(
        Injector.i.resolve<OrderTrackingRepository>(),
        isA<RemoteOrderTrackingRepository>(),
      );
    });

    test('registra tambien los dos cubits', () {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: true));

      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(Injector.i.resolve<OrderListCubit>(), isA<OrderListCubit>());
      expect(
        Injector.i.resolve<OrderNotificationCubit>(),
        isA<OrderNotificationCubit>(),
      );
    });
  });

  group('factories de widgets', () {
    test('buildNotificationBell devuelve una NotificationBell', () {
      expect(
        OrderTrackingFeatureBuilder.buildNotificationBell(),
        isA<NotificationBell>(),
      );
    });

    test('buildNotificationsPage devuelve un Widget', () {
      expect(
        OrderTrackingFeatureBuilder.buildNotificationsPage(),
        isA<Widget>(),
      );
    });
  });

  group('startNotifications', () {
    test('arranca el listener del cubit registrado', () async {
      final repo = FakeOrderTrackingRepository();
      final cubit = OrderNotificationCubit(repo);
      registerMock<OrderNotificationCubit>(cubit);

      OrderTrackingFeatureBuilder.startNotifications();
      repo.statusChangeController.add(const OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      ));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.notifications, hasLength(1));

      await cubit.close();
      await repo.dispose();
    });
  });

  group('SnackBar de cambio de estado', () {
    testWidgets('no explota cuando todavia no hay messenger montado',
        (tester) async {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: true));

      // El guard `if (messenger == null) return;` es el camino que corre
      // cuando llega un evento del WS antes de que el arbol este montado.
      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      expect(tester.takeException(), isNull);
    });

    testWidgets('muestra el id y el estado nuevo cuando hay messenger',
        (tester) async {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: true));

      final repo = FakeOrderTrackingRepository();
      registerMock<OrderTrackingRepository>(repo);
      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: OrderTrackingFeatureBuilder.scaffoldMessengerKey,
        home: const Scaffold(body: SizedBox()),
      ));

      OrderTrackingFeatureBuilder.startNotifications();
      repo.statusChangeController.add(const OrderStatusChange(
        orderId: 'WH-49281',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.completed,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('WH-49281'), findsOneWidget);
      expect(find.text('Completado'), findsOneWidget);
      expect(find.text('Ver'), findsOneWidget);

      await repo.dispose();
    });

    testWidgets('el boton Ver navega al detalle de esa orden', (tester) async {
      _registerCollaborators();
      registerMock<AppDataSource>(AppDataSource(isMock: true));

      final repo = FakeOrderTrackingRepository();
      registerMock<OrderTrackingRepository>(repo);
      OrderTrackingFeatureBuilder.injectDependencies(baseUrl: 'http://x');

      await tester.pumpWidget(MaterialApp(
        scaffoldMessengerKey: OrderTrackingFeatureBuilder.scaffoldMessengerKey,
        home: const Scaffold(body: SizedBox()),
      ));

      OrderTrackingFeatureBuilder.startNotifications();
      repo.statusChangeController.add(const OrderStatusChange(
        orderId: 'WH-49281',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.completed,
      ));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Ver'));
      await tester.pump();

      final nav = Injector.i.resolve<NavigationHelper>();
      verify(() => nav.pushNamed(any(), routeName: any(named: 'routeName')))
          .called(1);

      await repo.dispose();
    });
  });
}
```

- [ ] **Step 3: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/order_tracking_feature_builder_test.dart
```
Expected: FAIL.

This is the most environment-sensitive task in the plan. Expect to adjust:

- **`AppDataSource`'s constructor.** `AppDataSource(isMock: true)` is a guess from its usage. Step 1 tells you the real shape; if it is an enum or a class with a different constructor, use that.
- **`registerMock<OrderTrackingRepository>` before `injectDependencies`.** `injectDependencies` uses `registerLazySingleton`, and `GetIt` throws on a duplicate registration. If it does, call `resetInjector()` and register the fake *after* `injectDependencies`, or skip `injectDependencies` in the SnackBar tests and register the notification cubit directly.
- **Two `pump`s after the event.** The chain is stream → cubit emit → `onEvent` → `showSnackBar` → frame. If the SnackBar is not found, add another `await tester.pump()` rather than a `pumpAndSettle` — the SnackBar has a 5-second duration and `pumpAndSettle` will time out waiting for it to disappear.

If `injectDependencies` proves untestable without changing production code, **stop and report**. Do not refactor the feature builder inside a coverage task. The floor is reachable without this file: skipping all 60 lines still leaves roughly 409/514 ≈ 80%, which is right at the line — so report the number before deciding.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/order_tracking_feature_builder_test.dart
```
Expected: PASS, 9 tests.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/order_tracking_feature_builder_test.dart && git commit -m "test(order_tracking): cubrir el feature builder y la SnackBar de notificaciones"
```

---

## Task 11: RemoteOrderTrackingRepository — the reachable branches

The WS loops are out of scope (see "What this plan deliberately does NOT test"). What remains reachable: `getOrders`' aggregation over `OrderHistoryStore`, `getOrderById`'s contract parsing, and `_mapError`'s status-code mapping.

**Files:**
- Modify: `packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart`

**Interfaces:**
- Consumes: the `_FakeHttpHelper` and `_FakeHistoryStore` already in that file
- Produces: nothing later tasks depend on

- [ ] **Step 1: Read the existing file**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart
```
It already has `_FakeHttpHelper` (with a reassignable `getHandler`) and `_FakeHistoryStore` (with a settable `ids`). Reuse them; do not add a second pair.

Leave these two fakes local. They are not shared: `HttpHelper` mocks belong to `test_support` per spec §4.3, but this file's fake carries a response-shaping handler specific to these tests.

- [ ] **Step 2: Append the failing tests**

Add to the existing `main()`, keeping the file's current `setUp`:

```dart
  group('getOrders', () {
    test('sin ids en el historial devuelve lista vacia sin pegarle al back',
        () async {
      store.ids = const [];
      var calls = 0;
      fakeHttp.getHandler = (_) {
        calls++;
        return Right(HttpResponse(data: <String, dynamic>{}));
      };

      final result = await repo.getOrders();

      expect(result.getOrElse(() => [null as dynamic]), isEmpty);
      expect(calls, 0);
    });

    test('filtra las ordenes que fallan y conserva las que responden',
        () async {
      store.ids = const ['ok-1', 'falla'];
      fakeHttp.getHandler = (path) => path.endsWith('falla')
          ? const Left(HttpResponseError(statusCode: 404))
          : Right(HttpResponse(data: <String, dynamic>{
              'order': {
                'id': 'ok-1',
                'status': 'pending',
                'items': <dynamic>[],
              },
            }));

      final result = await repo.getOrders();

      final orders = result.getOrElse(() => []);
      expect(orders, hasLength(1));
      expect(orders.single.id, 'ok-1');
    });

    test('ordena por fecha descendente', () async {
      store.ids = const ['vieja', 'nueva'];
      fakeHttp.getHandler = (path) => Right(HttpResponse(data: <String, dynamic>{
            'order': {
              'id': path.endsWith('nueva') ? 'nueva' : 'vieja',
              'status': 'pending',
              'items': <dynamic>[],
              'created_at': path.endsWith('nueva')
                  ? '2026-03-02T10:00:00Z'
                  : '2026-01-01T10:00:00Z',
            },
          }));

      final result = await repo.getOrders();

      expect(
        result.getOrElse(() => []).map((o) => o.id),
        ['nueva', 'vieja'],
      );
    });
  });

  group('getOrderById', () {
    test('una respuesta que no es un mapa da Respuesta invalida', () async {
      fakeHttp.getHandler = (_) => Right(HttpResponse(data: 'no soy un mapa'));

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'Respuesta inválida',
      );
    });
  });

  group('mapeo de errores HTTP', () {
    test('404 dice que la orden no existe', () async {
      fakeHttp.getHandler =
          (_) => const Left(HttpResponseError(statusCode: 404));

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'Orden no encontrada',
      );
    });

    test('401 dice que no hay permisos', () async {
      fakeHttp.getHandler =
          (_) => const Left(HttpResponseError(statusCode: 401));

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'Sin permisos para ver órdenes',
      );
    });

    test('403 dice lo mismo que 401', () async {
      fakeHttp.getHandler =
          (_) => const Left(HttpResponseError(statusCode: 403));

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'Sin permisos para ver órdenes',
      );
    });

    test('un status desconocido propaga el mensaje del back', () async {
      fakeHttp.getHandler = (_) => const Left(
            HttpResponseError(statusCode: 500, message: 'boom del server'),
          );

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'boom del server',
      );
    });

    test('un status desconocido sin mensaje cae a Error de red', () async {
      fakeHttp.getHandler =
          (_) => const Left(HttpResponseError(statusCode: 500));

      final result = await repo.getOrderById('o-1');

      expect(
        result.swap().getOrElse(() => const OrderTrackingFailure()).message,
        'Error de red',
      );
    });
  });
```

- [ ] **Step 3: Run it and watch it fail**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/data/repositories/remote_order_tracking_repository_test.dart
```
Expected: FAIL.

**`HttpResponseError`'s real constructor** is the likely first break — `statusCode` and `message` are guesses. Read it:

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && cat packages/commons/lib/helpers/http/entities/http_response_error.dart
```

**The JSON shape** for `OrderTrackingDetailResponseDto` is the second. The existing tests in this file already build valid payloads — copy their shape rather than the sketch above.

- [ ] **Step 4: Run it and watch it pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub test/data/repositories/remote_order_tracking_repository_test.dart
```
Expected: PASS, the original tests plus 10 new ones.

- [ ] **Step 5: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test/data/repositories/remote_order_tracking_repository_test.dart && git commit -m "test(order_tracking): cubrir el mapeo de errores HTTP y la agregacion de getOrders"
```

---

## Task 12: Close the small remainders

Four files sit just short: the mock repo (5 lines), `OrderDetailCubit` (5), the mapper (1) and two DTOs (4).

**Files:**
- Modify: `packages/features/order_tracking/test/data/repositories/mock_order_tracking_repository_test.dart`
- Modify: `packages/features/order_tracking/test/data/mappers/order_tracking_mapper_test.dart`
- Modify: `packages/features/order_tracking/test/presentation/bloc/order_detail_cubit_test.dart`

**Interfaces:**
- Consumes: `FakeCatalogRepository`, `anOrder`, `anOrderItem`
- Produces: nothing later tasks depend on

- [ ] **Step 1: Find the exact uncovered lines**

Do not guess. After a coverage run, list them:

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/gen_coverage_imports.dart && cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub --coverage && grep -A 200 "mock_order_tracking_repository.dart" coverage/lcov.info | grep "^DA:.*,0$"
```
Repeat the `grep` for `order_detail_cubit.dart` and `order_tracking_mapper.dart`. Open each file at those line numbers and write a test for what lives there.

- [ ] **Step 2: Add the mock repository cases**

Each snippet below goes into an existing file, so add whatever imports it needs to that file's header. Across Steps 2–4 those are:

```dart
import 'package:catalog_test_builders/catalog_test_builders.dart';   // FakeCatalogRepository
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';                                  // Order, OrderStatus
import 'package:orders_test_builders/orders_test_builders.dart';      // anOrder
```

plus `import '../../support/fake_order_tracking_repository.dart';` in the detail-cubit file (adjust the relative depth to that file's location).

The uncovered lines in the mock repository are most likely `emitUpdate`, `emitStatusChange` and `dispose` — the demo hooks nothing exercises yet. Add to the existing file:

```dart
  test('emitUpdate empuja la orden al stream de watchOrder', () async {
    final repo = MockOrderTrackingRepository();
    final received = <Order>[];
    final sub = repo.watchOrder('WH-49281').listen(received.add);
    await Future<void>.delayed(Duration.zero);

    repo.emitUpdate('WH-49281', anOrder(id: 'WH-49281'));
    await Future<void>.delayed(Duration.zero);

    expect(received, hasLength(2));
    await sub.cancel();
    repo.dispose();
  });

  test('emitStatusChange llega a watchOrderStatusChanges', () async {
    final repo = MockOrderTrackingRepository();
    final received = <OrderStatusChange>[];
    final sub = repo.watchOrderStatusChanges().listen(received.add);

    repo.emitStatusChange(const OrderStatusChange(
      orderId: 'WH-49281',
      oldStatus: OrderStatus.pending,
      newStatus: OrderStatus.completed,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(received.single.newStatus, OrderStatus.completed);
    await sub.cancel();
    repo.dispose();
  });

  test('watchOrder con un id desconocido cae a la primera orden', () async {
    final repo = MockOrderTrackingRepository();
    final received = <Order>[];
    final sub = repo.watchOrder('no-existe').listen(received.add);
    await Future<void>.delayed(Duration.zero);

    expect(received.single.id, 'WH-49281');
    await sub.cancel();
    repo.dispose();
  });
```

- [ ] **Step 3: Add the OrderDetailCubit cases**

The uncovered lines are most likely the terminal-status unsubscribe and the error path. Add:

```dart
  test('deja de escuchar cuando la orden llega a completed', () async {
    final repo = FakeOrderTrackingRepository();
    final cubit = OrderDetailCubit(repo, FakeCatalogRepository())..load('o-1');

    repo.orderController.add(anOrder(id: 'o-1', status: OrderStatus.completed));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    repo.orderController.add(anOrder(id: 'o-1', status: OrderStatus.pending));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = cubit.state as OrderDetailReady;
    expect(state.order.status, OrderStatus.completed);

    await cubit.close();
    await repo.dispose();
  });

  test('un error del stream emite OrderDetailError', () async {
    final repo = FakeOrderTrackingRepository();
    final cubit = OrderDetailCubit(repo, FakeCatalogRepository())..load('o-1');

    repo.orderController.addError(Exception('sin conexion'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state, isA<OrderDetailError>());

    await cubit.close();
    await repo.dispose();
  });

  test('un segundo load limpia el cache y reemite Loading', () async {
    final repo = FakeOrderTrackingRepository();
    final cubit = OrderDetailCubit(repo, FakeCatalogRepository())..load('o-1');
    repo.orderController.add(anOrder(id: 'o-1'));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    cubit.load('o-2');

    expect(cubit.state, isA<OrderDetailLoading>());

    await cubit.close();
    await repo.dispose();
  });
```

- [ ] **Step 4: Add the mapper's last case**

One uncovered line in `order_tracking_mapper.dart`. The likeliest candidate is the unparseable-date fallback to epoch. Add to the existing mapper test file:

```dart
  test('una fecha ilegible cae a epoch para que la orden quede al final', () {
    const dto = OrderTrackingItemDto(
      id: 'o-1',
      status: 'pending',
      items: [],
      createdAt: 'no soy una fecha',
    );

    expect(dto.toEntity().createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('sin fecha en ningun campo tambien cae a epoch', () {
    const dto = OrderTrackingItemDto(id: 'o-1', status: 'pending', items: []);

    expect(dto.toEntity().createdAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
```

Match `OrderTrackingItemDto`'s real constructor — it is Freezed, so the named parameters are whatever the DTO declares. Read it first.

- [ ] **Step 5: Run the whole package**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse/packages/features/order_tracking" && flutter test --no-pub
```
Expected: PASS, everything green.

- [ ] **Step 6: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add packages/features/order_tracking/test && git commit -m "test(order_tracking): cerrar los huecos del mock repo, el detalle y el mapper"
```

---

## Task 13: Raise the floor

**Files:**
- Modify: `coverage_thresholds.yaml`

**Interfaces:**
- Consumes: Tasks 3–12
- Produces: an enforced floor for `order_tracking`

- [ ] **Step 1: Measure**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" run test:coverage
```
Read `order_tracking`'s percentage from the printed table.

- [ ] **Step 2: Set the floor**

If `order_tracking` reached 80% or more, replace its block in `coverage_thresholds.yaml`:

```yaml
  order_tracking:
    path: packages/features/order_tracking
    # Medido en <X>% (<hit>/<found>) en #164, contra un target de 80%.
    # Lo que queda afuera son los dos loops de reconexion WS de
    # RemoteOrderTrackingRepository (_connectWithRetry y
    # _watchStatusChangesLoop): `while` infinitos sobre el WebSocketChannel
    # real y Future.delayed real, sin seam para inyectar un canal falso.
    # Cubrirlos pide o un parametro de factory en produccion o fake_async,
    # que el repo no usa en ningun lado. Ver el plan de #164.
    min: 80
```

Fill `<X>`, `<hit>` and `<found>` with the measured values. **Never set a floor above the measured value** — if it measured 84.2, `min: 80` is correct per the target; seeding a point below the measurement, as `orders` and `bottom_navigation_bar` do, is also acceptable if you want ratchet headroom.

If it did **not** reach 80%, do not invent a number and do not add an exclusion. List exactly which files and lines remain uncovered and report them. The expected shortfall, if any, is the feature builder (Task 10) or the WS loops. Say which, with the numbers.

- [ ] **Step 3: Verify the gate passes**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/check_coverage.dart
```
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git add coverage_thresholds.yaml && git commit -m "feat(coverage): subir floor de order_tracking a 80"
```

---

## Task 14: Full verification

**Files:** none

- [ ] **Step 1: Clean run of the whole workspace**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" bootstrap && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" run test:coverage
```
Expected: every package green, gate exit 0. A package other than `order_tracking` going red means Task 1's change to `catalog_test_builders` broke a consumer — `cart` and `bottom_navigation_bar` both depend on it.

- [ ] **Step 2: Analyze must be clean**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && "$HOME/AppData/Local/Pub/Cache/bin/melos.bat" exec -- flutter analyze
```
Expected: `No issues found!` everywhere.

- [ ] **Step 3: The tooling guards must still pass**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && flutter test --no-pub test/tool
```
Expected: 32 tests pass. `test_support_deps_test.dart` is the one that matters — it fails if anything added a feature dependency to `test_support`.

- [ ] **Step 4: The gate must still be able to fail**

A gate that cannot go red is not a gate. Temporarily raise `order_tracking`'s `min` by 20 points, confirm `dart run tool/check_coverage.dart` exits non-zero, then put it back.

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && dart run tool/check_coverage.dart; echo "exit: $?"
```

- [ ] **Step 5: Confirm the working tree carries only lock churn**

```bash
cd "C:/Users/Bauta/FACULTAD/EMERGENTES/Warehouse USAL/SmartWarehouse" && git status --short
```
Expected: only `pubspec.lock` files modified. Anything else means a step forgot to commit something.

- [ ] **Step 6: Report, do not push**

The branch this plan builds on is unpushed and depends on an unpushed commit. Summarize: the final percentage, the floor set, which files remain uncovered and why. Do not push or open a PR without asking — and flag Task 1's `FakeCatalogRepository` to whoever owns #163.

---

## Verification Checklist

- [ ] Every new test file was watched failing before its implementation or assertions were finalized
- [ ] `order_tracking` measures ≥ 80% and its floor in `coverage_thresholds.yaml` matches, never exceeding the measured value
- [ ] No exclusion was added to `coverage_thresholds.yaml` for anything that is not a thin platform adapter
- [ ] No page under `presentation/pages/` was tested
- [ ] No test asserts on padding, border radius or a hex color
- [ ] `order_list_cubit_test.dart` uses `blocTest`, not `stream.listen` + `Future.delayed`
- [ ] The hand-rolled `_FakeCatalog` is gone from `order_tracking`'s tests
- [ ] Nothing under `packages/features/orders/test/` was modified, and the `orders` floor is untouched
- [ ] `melos run test:coverage` is green for every package
- [ ] `melos exec -- flutter analyze` is clean
- [ ] `flutter test test/tool` passes, including `test_support_deps_test.dart`
- [ ] No `pubspec.lock` was committed
