# Phase 2a — test_support builders + auth + cart Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete `test_support` with the shared entity builders spec §4.3 promised, then bring `auth` and `cart` from ~0% to their 80% coverage floor.

**Architecture:** `test_support` gains builders for the entities shared across feature packages (`Money`, `Stock`, `Product`) plus a JSON fixture loader. `auth` and `cart` are then tested layer by layer following spec §4.1: repositories with mocked collaborators, cubits with `blocTest`, entities only where they carry hand-written logic.

**Tech Stack:** Dart 3.11.5, Flutter 3.41.9, melos 6.3.3, `mocktail`, `bloc_test`, `dartz` (`Either`/`Option`), lcov coverage gate.

**Spec:** `docs/superpowers/specs/2026-08-12-test-strategy-design.md`

**Scope:** This is plan **2a of 3** for Phase 2. It covers `test_support` completion plus `auth` (179 instrumentable lines) and `cart` (290). These two were grouped because neither has DTOs or mappers — they exercise the repository + cubit half of the conventions — and because the builders created here are consumed by plans 2b and 2c.

- **Plan 2b** (later): `orders`, `login`, `profile` — mid-size, all with mappers and DTOs.
- **Plan 2c** (later): `order_tracking`, `catalog` — largest, most DTOs, both already have partial suites to extend.

**Not in this plan:** GitHub bookkeeping. Issues #161 (`auth`) and #162 (`cart`) already exist with their checklists; move them on the wh-mobile board as work lands.

## Global Constraints

- Dart SDK constraint for all packages: `'>=3.8.0 <4.0.0'`
- Branch: `feature/e8.2-phase2a-auth-cart`, matching CI's `^(feature|fix|enhancement|refactor|hotfix|beta|backport|dependabot)/`
- **This plan builds on PR #170**, which is not yet merged. Branch from `feature/e8.2-phase0-coverage-infra`, not from `develop` — the coverage tooling, `test_support`, and `mocktail`/`bloc_test` dependencies all live there.
- Coverage floors only ever increase. Never set a floor above the measured value.
- Coverage denominator always excludes `**/*.g.dart` and `**/*.freezed.dart`
- Exclusions are legitimate **only** for thin platform adapters that merely delegate to a plugin, each with a one-line reason comment
- Targets (spec §5): `auth` 80, `cart` 80
- Commit messages: `type(scope): subject`, lowercase, Spanish subject
- `melos bootstrap` must run before any `flutter test`
- Run everything from the repo root; each shell invocation is fresh, so never rely on a previous `cd`

## Environment

- `melos` is at `~/.pub-cache/bin/melos` (6.3.3), not on `PATH` non-interactively: `export PATH="$PATH:$HOME/.pub-cache/bin"`
- `flutter` is at `/home/hechicero/Documents/flutterDev/flutter/bin/flutter`
- Run one package's tests with an absolute path in a single command:
  `cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test`
- Never `git add -A` — the working tree carries `pubspec.lock` churn from bootstrap

---

## File Structure

**Created:**
- `packages/test_support/lib/src/builders/money_builder.dart` — `aMoney()`
- `packages/test_support/lib/src/builders/stock_builder.dart` — `aStock()`
- `packages/test_support/lib/src/builders/product_builder.dart` — `aProduct()`
- `packages/test_support/lib/src/fixtures.dart` — `loadJsonFixture()`
- `packages/features/auth/test/domain/entities/auth_data_test.dart`
- `packages/features/auth/test/presentation/bloc/auth_cubit_token_test.dart`
- `packages/features/auth/test/data/repositories/local_auth_repository_test.dart`
- `packages/features/auth/test/presentation/bloc/auth_cubit_test.dart`
- `packages/features/auth/test/presentation/bloc/auth_cubit_refresh_test.dart`
- `packages/features/cart/test/domain/entities/cart_test.dart`
- `packages/features/cart/test/data/repositories/in_memory_cart_repository_test.dart`
- `packages/features/cart/test/presentation/bloc/cart_cubit_test.dart`

**Modified:**
- `packages/test_support/pubspec.yaml` — add `catalog` dependency
- `packages/test_support/lib/test_support.dart` — export builders and fixtures
- `packages/features/auth/pubspec.yaml`, `packages/features/cart/pubspec.yaml` — add `test_support` dev dependency
- `coverage_thresholds.yaml` — raise `auth` and `cart` floors

**Why builders live where they do.** Builders for entities shared across packages (`Money`, `Stock`, `Product`) go in `test_support`, since `cart`, `orders`, `order_tracking` and `catalog` all need them. Builders for entities owned by a single package (`AuthData`) stay in that package's own `test/` directory — putting them in `test_support` would force it to depend on every feature package. Spec §4.3 asked for central builders; this is that, bounded by the rule "central only if shared."

---

## Task 1: test_support builders and fixture loading

**Files:**
- Modify: `packages/test_support/pubspec.yaml`
- Create: `packages/test_support/lib/src/builders/money_builder.dart`
- Create: `packages/test_support/lib/src/builders/stock_builder.dart`
- Create: `packages/test_support/lib/src/builders/product_builder.dart`
- Create: `packages/test_support/lib/src/fixtures.dart`
- Modify: `packages/test_support/lib/test_support.dart`

**Interfaces:**
- Consumes: `Money`, `Stock`, `Product`, `ProductCategory`, `OrderConstraints` from `package:catalog/catalog.dart`
- Produces, all exported from `package:test_support/test_support.dart`:
  - `Money aMoney({int amount, String currency, bool? taxIncluded})`
  - `Stock aStock({int available, int? min, int? reserved, int? lowStockThreshold})`
  - `Product aProduct({String id, String sku, String name, ProductCategory category, Money? price, Stock? stock, OrderConstraints? orderConstraints, String? imageUrl, String? description})`
  - `Map<String, dynamic> loadJsonFixture(String path)`

- [ ] **Step 1: Add the catalog dependency**

In `packages/test_support/pubspec.yaml`, under `dependencies:`, after the `commons:` entry, add:

```yaml
  catalog:
    path: ../features/catalog
```

`test_support` now depends on `commons` and `catalog` only. Do not add other feature packages — see "Why builders live where they do" above.

- [ ] **Step 2: Read the real constructors before writing builders**

Open and read these, because the builders must match them exactly:
- `packages/features/catalog/lib/src/domain/entities/money.dart`
- `packages/features/catalog/lib/src/domain/entities/stock.dart`
- `packages/features/catalog/lib/src/domain/entities/product.dart`
- `packages/features/catalog/lib/src/domain/entities/order_constraints.dart`
- `packages/features/catalog/lib/src/domain/entities/product_category.dart`

If any constructor differs from what this plan assumes, follow the source and report the difference. Do not edit the entities to match the plan.

- [ ] **Step 3: Write the Money builder**

Create `packages/test_support/lib/src/builders/money_builder.dart`:

```dart
import 'package:catalog/catalog.dart';

/// Construye un [Money] con defaults razonables.
///
/// `amount` está en centavos (minor units), igual que el contrato del backend.
/// El default de 1000 = $10,00 evita el caso degenerado de 0, que esconde
/// bugs de multiplicación y suma.
Money aMoney({
  int amount = 1000,
  String currency = 'ARS',
  bool? taxIncluded,
}) =>
    Money(amount: amount, currency: currency, taxIncluded: taxIncluded);
```

- [ ] **Step 4: Write the Stock builder**

Create `packages/test_support/lib/src/builders/stock_builder.dart`:

```dart
import 'package:catalog/catalog.dart';

/// Construye un [Stock] con defaults razonables.
///
/// El default de 10 disponibles deja el producto comprable sin estar en
/// stock bajo: los tests que necesitan agotado o bajo lo piden explícito.
Stock aStock({
  int available = 10,
  int? min,
  int? reserved,
  int? lowStockThreshold,
}) =>
    Stock(
      available: available,
      min: min,
      reserved: reserved,
      lowStockThreshold: lowStockThreshold,
    );
```

- [ ] **Step 5: Write the Product builder**

Create `packages/test_support/lib/src/builders/product_builder.dart`:

```dart
import 'package:catalog/catalog.dart';

import 'money_builder.dart';
import 'stock_builder.dart';

/// Construye un [Product] con defaults razonables.
///
/// `Product` define `==` solo por `id`, así que dos productos con el mismo id
/// son iguales aunque difieran en todo lo demás. Los tests que dependen de
/// distinguir productos tienen que pasar ids distintos.
Product aProduct({
  String id = 'p-1',
  String sku = 'SKU-1',
  String name = 'Producto de prueba',
  ProductCategory category = ProductCategory.herramientas,
  Money? price,
  Stock? stock,
  OrderConstraints? orderConstraints,
  String? imageUrl,
  String? description,
}) =>
    Product(
      id: id,
      sku: sku,
      name: name,
      category: category,
      price: price ?? aMoney(),
      stock: stock ?? aStock(),
      orderConstraints:
          orderConstraints ?? const OrderConstraints(maxQuantityPerOrder: 5),
      imageUrl: imageUrl,
      description: description,
    );
```

Both types were verified against source while writing this plan: `ProductCategory` is an enum whose values are `tecnologia`, `herramientas`, `alimentos`, `otros` (each carrying a `key` and a `label`), and `OrderConstraints` takes a single required `maxQuantityPerOrder`. It also exposes `OrderConstraints.defaults` (99), which is deliberately **not** used as the builder default — 5 is small enough that a test can exceed it without constructing an absurd quantity.

- [ ] **Step 6: Write the fixture loader**

Create `packages/test_support/lib/src/fixtures.dart`:

```dart
import 'dart:convert';
import 'dart:io';

/// Lee un fixture JSON desde el directorio `test/fixtures/` del package que
/// está corriendo el test.
///
/// `flutter test` corre con el cwd en la raíz del package, así que la ruta es
/// relativa a ahí. Tirar un error claro cuando falta el archivo evita el
/// clásico "Unexpected end of input" de intentar parsear un string vacío.
Map<String, dynamic> loadJsonFixture(String path) {
  final file = File('test/fixtures/$path');
  if (!file.existsSync()) {
    throw StateError(
      'No se encontró el fixture test/fixtures/$path '
      '(cwd: ${Directory.current.path})',
    );
  }
  final decoded = json.decode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    throw StateError('El fixture test/fixtures/$path no es un objeto JSON');
  }
  return decoded;
}
```

- [ ] **Step 7: Export everything**

Replace `packages/test_support/lib/test_support.dart` with:

```dart
library test_support;

export 'src/builders/money_builder.dart';
export 'src/builders/product_builder.dart';
export 'src/builders/stock_builder.dart';
export 'src/fixtures.dart';
export 'src/injector_harness.dart';
export 'src/mocks.dart';
```

- [ ] **Step 8: Verify it analyzes**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos bootstrap && melos exec -- flutter analyze
```
Expected: `No issues found!` in every package.

- [ ] **Step 9: Commit**

```bash
git add packages/test_support
git commit -m "feat(test_support): builders de entities compartidas y carga de fixtures"
```

---

## Task 2: cart — Cart and CartItem entities

`Cart` and `CartItem` are hand-written (not Freezed), so per spec §4.1 their logic gets tested: `itemCount`, `total`, `quantityOf`, `subtotal`, `copyWith`.

**Files:**
- Modify: `packages/features/cart/pubspec.yaml`
- Create: `packages/features/cart/test/domain/entities/cart_test.dart`

**Interfaces:**
- Consumes: `aProduct`, `aMoney` from `package:test_support/test_support.dart` (Task 1)
- Produces: nothing new

- [ ] **Step 1: Add the test_support dev dependency**

In `packages/features/cart/pubspec.yaml`, under `dev_dependencies:`, add:

```yaml
  test_support:
    path: ../../test_support
```

Then: `cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos bootstrap`

- [ ] **Step 2: Write the test**

Create `packages/features/cart/test/domain/entities/cart_test.dart`:

```dart
import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

void main() {
  group('CartItem', () {
    test('subtotal multiplies the unit price by the quantity', () {
      final item = CartItem(
        product: aProduct(price: aMoney(amount: 2500)),
        quantity: 3,
      );

      expect(item.subtotal, aMoney(amount: 7500));
    });

    test('subtotal of a single unit equals the unit price', () {
      final item = CartItem(
        product: aProduct(price: aMoney(amount: 999)),
        quantity: 1,
      );

      expect(item.subtotal, aMoney(amount: 999));
    });

    test('copyWith replaces the quantity and keeps the product', () {
      final product = aProduct(id: 'p-9');
      final item = CartItem(product: product, quantity: 1);

      final updated = item.copyWith(quantity: 4);

      expect(updated.quantity, 4);
      expect(updated.product.id, 'p-9');
    });

    test('copyWith with no argument keeps the quantity', () {
      final item = CartItem(product: aProduct(), quantity: 2);

      expect(item.copyWith().quantity, 2);
    });
  });

  group('Cart.empty', () {
    test('has no items and reports empty', () {
      final cart = Cart.empty();

      expect(cart.items, isEmpty);
      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
      expect(cart.itemCount, 0);
    });

    test('total is null when there is no currency of reference', () {
      expect(Cart.empty().total, isNull);
    });
  });

  group('Cart.itemCount', () {
    test('sums quantities rather than counting lines', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'a'), quantity: 2),
        CartItem(product: aProduct(id: 'b'), quantity: 3),
      ]);

      expect(cart.itemCount, 5);
    });
  });

  group('Cart.total', () {
    test('sums the subtotals of every line', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'a', price: aMoney(amount: 1000)), quantity: 2),
        CartItem(product: aProduct(id: 'b', price: aMoney(amount: 500)), quantity: 1),
      ]);

      expect(cart.total, aMoney(amount: 2500));
    });

    test('keeps the currency of the first item', () {
      final cart = Cart(items: [
        CartItem(
          product: aProduct(price: aMoney(amount: 100, currency: 'USD')),
          quantity: 1,
        ),
      ]);

      expect(cart.total?.currency, 'USD');
    });

    test('throws when the cart mixes currencies', () {
      final cart = Cart(items: [
        CartItem(
          product: aProduct(id: 'a', price: aMoney(amount: 100, currency: 'ARS')),
          quantity: 1,
        ),
        CartItem(
          product: aProduct(id: 'b', price: aMoney(amount: 100, currency: 'USD')),
          quantity: 1,
        ),
      ]);

      expect(() => cart.total, throwsArgumentError);
    });
  });

  group('Cart.quantityOf', () {
    test('returns the quantity of a product in the cart', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'p-7'), quantity: 3),
      ]);

      expect(cart.quantityOf('p-7'), 3);
    });

    test('returns zero for a product that is not in the cart', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'p-7'), quantity: 3),
      ]);

      expect(cart.quantityOf('p-otro'), 0);
    });

    test('returns zero for an empty cart', () {
      expect(Cart.empty().quantityOf('p-1'), 0);
    });
  });
}
```

- [ ] **Step 3: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/cart && flutter test test/domain/entities/cart_test.dart
```
Expected: PASS — 13 tests.

These are characterization tests: the entities already exist and are believed correct, so there is no red phase. **If the mixed-currency test fails, that is a real finding** — it means `Money.+` no longer throws on a currency mismatch, and silent cross-currency addition in a shopping cart is a money bug. Report it; do not weaken the test.

- [ ] **Step 4: Commit**

```bash
git add packages/features/cart/test packages/features/cart/pubspec.yaml packages/features/cart/pubspec.lock
git commit -m "test(cart): cobertura de Cart y CartItem"
```

---

## Task 3: cart — InMemoryCartRepository

**Files:**
- Create: `packages/features/cart/test/data/repositories/in_memory_cart_repository_test.dart`

**Interfaces:**
- Consumes: `aProduct`, `aMoney` from `package:test_support/test_support.dart`
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/cart/test/data/repositories/in_memory_cart_repository_test.dart`:

```dart
import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

void main() {
  late InMemoryCartRepository repo;

  setUp(() => repo = InMemoryCartRepository());

  group('add', () {
    test('adds a new product as one line', () {
      repo.add(aProduct(id: 'p-1'));

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 1);
    });

    test('adds the requested quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: 3);

      expect(repo.current.quantityOf('p-1'), 3);
    });

    test('accumulates onto the existing line instead of duplicating it', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);
      repo.add(aProduct(id: 'p-1'), quantity: 3);

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 5);
    });

    test('keeps different products on separate lines', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      expect(repo.current.items, hasLength(2));
    });

    test('ignores a quantity of zero', () {
      repo.add(aProduct(id: 'p-1'), quantity: 0);

      expect(repo.current.isEmpty, isTrue);
    });

    test('ignores a negative quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: -2);

      expect(repo.current.isEmpty, isTrue);
    });
  });

  group('remove', () {
    test('drops the line for that product', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      repo.remove('p-1');

      expect(repo.current.items, hasLength(1));
      expect(repo.current.quantityOf('p-1'), 0);
    });

    test('is a no-op for a product that is not in the cart', () {
      repo.add(aProduct(id: 'p-1'));

      repo.remove('p-inexistente');

      expect(repo.current.items, hasLength(1));
    });
  });

  group('updateQuantity', () {
    test('sets the quantity of an existing line', () {
      repo.add(aProduct(id: 'p-1'), quantity: 1);

      repo.updateQuantity('p-1', 7);

      expect(repo.current.quantityOf('p-1'), 7);
    });

    test('removes the line when the quantity drops to zero', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-1', 0);

      expect(repo.current.isEmpty, isTrue);
    });

    test('removes the line for a negative quantity', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-1', -1);

      expect(repo.current.isEmpty, isTrue);
    });

    test('is a no-op for a product that is not in the cart', () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);

      repo.updateQuantity('p-inexistente', 9);

      expect(repo.current.quantityOf('p-1'), 2);
      expect(repo.current.items, hasLength(1));
    });
  });

  group('clear', () {
    test('empties the cart', () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));

      repo.clear();

      expect(repo.current.isEmpty, isTrue);
    });

    test('is a no-op on an already empty cart', () {
      repo.clear();

      expect(repo.current.isEmpty, isTrue);
    });
  });

  group('current', () {
    test('returns an unmodifiable view, so callers cannot mutate the store', () {
      repo.add(aProduct(id: 'p-1'));

      expect(
        () => repo.current.items.add(
          repo.current.items.first,
        ),
        throwsUnsupportedError,
      );
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/cart && flutter test test/data/repositories/in_memory_cart_repository_test.dart
```
Expected: PASS — 15 tests.

- [ ] **Step 3: Commit**

```bash
git add packages/features/cart/test/data
git commit -m "test(cart): cobertura de InMemoryCartRepository"
```

---

## Task 4: cart — CartCubit

`CartCubit` extends `Cubit<Cart>`, and **`Cart` does not implement `==`**. Two carts with identical contents are different objects, so `blocTest`'s `expect` cannot compare `Cart` instances directly — every expectation must match on fields via `predicate` or `isA<Cart>().having(...)`.

**Files:**
- Create: `packages/features/cart/test/presentation/bloc/cart_cubit_test.dart`

**Interfaces:**
- Consumes: `aProduct` from `package:test_support/test_support.dart`; `InMemoryCartRepository`
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/cart/test/presentation/bloc/cart_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

/// `Cart` no implementa `==`, así que no se puede comparar instancias en el
/// `expect` de blocTest. Este matcher afirma sobre los campos.
Matcher cartWith({required int itemCount, required int lineCount}) =>
    isA<Cart>()
        .having((c) => c.itemCount, 'itemCount', itemCount)
        .having((c) => c.items.length, 'lineCount', lineCount);

void main() {
  late InMemoryCartRepository repo;

  setUp(() => repo = InMemoryCartRepository());

  test('initial state is the repository current cart', () {
    repo.add(aProduct(id: 'p-1'), quantity: 2);

    final cubit = CartCubit(repo);

    expect(cubit.state.itemCount, 2);
    cubit.close();
  });

  test('initial state of an empty repository is an empty cart', () {
    final cubit = CartCubit(repo);

    expect(cubit.state.isEmpty, isTrue);
    cubit.close();
  });

  blocTest<CartCubit, Cart>(
    'add emits a cart containing the product',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.add(aProduct(id: 'p-1')),
    expect: () => [cartWith(itemCount: 1, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'add with a quantity emits that quantity',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.add(aProduct(id: 'p-1'), quantity: 4),
    expect: () => [cartWith(itemCount: 4, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'adding the same product twice accumulates onto one line',
    build: () => CartCubit(repo),
    act: (cubit) => cubit
      ..add(aProduct(id: 'p-1'), quantity: 2)
      ..add(aProduct(id: 'p-1'), quantity: 3),
    expect: () => [
      cartWith(itemCount: 2, lineCount: 1),
      cartWith(itemCount: 5, lineCount: 1),
    ],
  );

  blocTest<CartCubit, Cart>(
    'remove emits a cart without that product',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'));
      repo.add(aProduct(id: 'p-2'));
      return repo.current;
    },
    act: (cubit) => cubit.remove('p-1'),
    expect: () => [cartWith(itemCount: 1, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'updateQuantity emits the new quantity',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 1);
      return repo.current;
    },
    act: (cubit) => cubit.updateQuantity('p-1', 6),
    expect: () => [cartWith(itemCount: 6, lineCount: 1)],
  );

  blocTest<CartCubit, Cart>(
    'updateQuantity to zero emits an empty cart',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 3);
      return repo.current;
    },
    act: (cubit) => cubit.updateQuantity('p-1', 0),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );

  blocTest<CartCubit, Cart>(
    'clear emits an empty cart',
    build: () => CartCubit(repo),
    seed: () {
      repo.add(aProduct(id: 'p-1'), quantity: 2);
      repo.add(aProduct(id: 'p-2'), quantity: 1);
      return repo.current;
    },
    act: (cubit) => cubit.clear(),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );

  blocTest<CartCubit, Cart>(
    'every action emits, even when the resulting cart is unchanged',
    build: () => CartCubit(repo),
    act: (cubit) => cubit.remove('p-inexistente'),
    expect: () => [cartWith(itemCount: 0, lineCount: 0)],
  );
}
```

The last test pins a real consequence of `Cart` lacking `==`: `Cubit.emit` normally suppresses an emission when the new state equals the current one, but since every `repo.current` is a fresh object, the cubit emits even for a no-op. That is current behaviour and the UI depends on it not silently skipping rebuilds.

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/cart && flutter test test/presentation/bloc/cart_cubit_test.dart
```
Expected: PASS — 10 tests.

- [ ] **Step 3: Commit**

```bash
git add packages/features/cart/test/presentation
git commit -m "test(cart): cobertura de CartCubit con blocTest"
```

---

## Task 5: Raise the cart floor

**Files:**
- Modify: `coverage_thresholds.yaml`

**Interfaces:**
- Consumes: Tasks 2–4
- Produces: an enforced floor for `cart`

- [ ] **Step 1: Measure**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos run test:coverage
```
Read `cart`'s percentage from the printed table.

- [ ] **Step 2: Set the floor**

If `cart` reached 80% or more, set `cart` `min: 80` in `coverage_thresholds.yaml`.

If it did not, do **not** invent a number and do **not** exclude real logic to reach it. Identify precisely which files and lines are uncovered and report them. `cart`'s remaining uncovered code will be its pages and widgets (`cart_page.dart`, `cart_item_tile.dart`, `quantity_stepper.dart`, `create_order_confirmation_dialog.dart`, `cart_badge.dart`) — per spec §4.1 pages are out of scope, but widgets **with logic** are in scope. If the gap is those widgets, say so and I will rule on whether to test them here or adjust the target.

Never set a floor above the measured value.

- [ ] **Step 3: Verify the gate passes**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && dart run tool/check_coverage.dart
```
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add coverage_thresholds.yaml
git commit -m "feat(coverage): subir floor de cart"
```

---

## Task 6: auth — AuthData and the local builder

**Files:**
- Modify: `packages/features/auth/pubspec.yaml`
- Create: `packages/features/auth/test/support/auth_builders.dart`
- Create: `packages/features/auth/test/domain/entities/auth_data_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks
- Produces: `AuthData anAuthData({String token, String? refreshToken})`, importable by later auth tests as `import '../../support/auth_builders.dart';` (adjust the relative depth per test file location)

- [ ] **Step 1: Add the test_support dev dependency**

In `packages/features/auth/pubspec.yaml`, under `dev_dependencies:`, add:

```yaml
  test_support:
    path: ../../test_support
```

Then: `cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos bootstrap`

- [ ] **Step 2: Write the local builder**

`AuthData` belongs to `auth` alone, so its builder stays local rather than pushing an `auth` dependency into `test_support`.

Create `packages/features/auth/test/support/auth_builders.dart`:

```dart
import 'package:auth/src/domain/entities/auth_data.dart';

/// Construye un [AuthData] con defaults razonables.
///
/// Vive acá y no en `test_support` porque `AuthData` lo usa solo este package:
/// centralizarlo obligaría a `test_support` a depender de `auth`.
AuthData anAuthData({
  String token = 'token-de-prueba',
  String? refreshToken = 'refresh-de-prueba',
}) =>
    AuthData(token: token, refreshToken: refreshToken);
```

- [ ] **Step 3: Write the entity test**

Create `packages/features/auth/test/domain/entities/auth_data_test.dart`:

```dart
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/auth_builders.dart';

void main() {
  test('empty has a blank token and a blank refresh token', () {
    final data = AuthData.empty();

    expect(data.token, '');
    expect(data.refreshToken, '');
  });

  test('two instances with the same fields are equal', () {
    expect(
      anAuthData(token: 't', refreshToken: 'r'),
      anAuthData(token: 't', refreshToken: 'r'),
    );
  });

  test('a different token makes them unequal', () {
    expect(
      anAuthData(token: 'a'),
      isNot(anAuthData(token: 'b')),
    );
  });

  test('a different refresh token makes them unequal', () {
    expect(
      anAuthData(token: 't', refreshToken: 'a'),
      isNot(anAuthData(token: 't', refreshToken: 'b')),
    );
  });

  test('equal instances share a hashCode', () {
    expect(
      anAuthData(token: 't', refreshToken: 'r').hashCode,
      anAuthData(token: 't', refreshToken: 'r').hashCode,
    );
  });

  test('refreshToken may be null', () {
    expect(anAuthData(refreshToken: null).refreshToken, isNull);
  });
}
```

- [ ] **Step 4: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test test/domain
```
Expected: PASS — 6 tests.

- [ ] **Step 5: Commit**

```bash
git add packages/features/auth/test packages/features/auth/pubspec.yaml packages/features/auth/pubspec.lock
git commit -m "test(auth): cobertura de AuthData y builder local"
```

---

## Task 7: auth — LocalAuthRepository

`LocalAuthRepository` wraps `PersistenceHelper` and `HttpHelper`, both of which have ready-made mocks in `test_support`. Note the interface shapes: `save`/`remove` return `Future<Option<AuthFailure>>` where `None` means success, while `load`/`refresh` return `Future<Either<AuthFailure, AuthData?>>`.

**Files:**
- Create: `packages/features/auth/test/data/repositories/local_auth_repository_test.dart`

**Interfaces:**
- Consumes: `MockPersistenceHelper`, `MockHttpHelper` from `package:test_support/test_support.dart`; `anAuthData` from Task 6
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/auth/test/data/repositories/local_auth_repository_test.dart`:

```dart
import 'package:auth/src/data/models/persistable_auth_data.dart';
import 'package:auth/src/data/repositories/local_auth_repository.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

import '../../support/auth_builders.dart';

class _FakePersistableAuthData extends Fake implements PersistableObject {}

void main() {
  late MockPersistenceHelper persistence;
  late MockHttpHelper http;
  late LocalAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakePersistableAuthData());
  });

  setUp(() {
    persistence = MockPersistenceHelper();
    http = MockHttpHelper();
    repo = LocalAuthRepository(httpHelper: http, persistenceHelper: persistence);
  });

  group('load', () {
    test('returns Right(null) when nothing is persisted', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => false);

      final result = await repo.load();

      expect(result, const Right<AuthFailure, AuthData?>(null));
      verifyNever(() => persistence.get<PersistableAuthData>(any(), any()));
    });

    test('returns the persisted auth data', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Right(
          PersistableAuthData(token: 'tok', refreshToken: 'ref'),
        ),
      );

      final result = await repo.load();

      final data = result.getOrElse(() => null);
      expect(data?.token, 'tok');
      expect(data?.refreshToken, 'ref');
    });

    test('treats a persisted empty token as no session', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Right(PersistableAuthData(token: '')),
      );

      final result = await repo.load();

      expect(result.getOrElse(() => anAuthData()), isNull);
    });

    test('returns a failure when persistence fails', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Left(PersistenceFailure.notFound()),
      );

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });

    test('returns a failure when persistence throws', () async {
      when(() => persistence.exists(any())).thenThrow(Exception('boom'));

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });
  });

  group('save', () {
    test('returns None when persistence succeeds', () async {
      when(() => persistence.set(any(), any()))
          .thenAnswer((_) async => const None());

      final result = await repo.save(anAuthData());

      expect(result.isNone(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence fails', () async {
      when(() => persistence.set(any(), any())).thenAnswer(
        (_) async => const Some(PersistenceFailure.other('disco lleno')),
      );

      final result = await repo.save(anAuthData());

      expect(result.isSome(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence throws', () async {
      when(() => persistence.set(any(), any())).thenThrow(Exception('boom'));

      final result = await repo.save(anAuthData());

      expect(result.isSome(), isTrue);
    });
  });

  group('remove', () {
    test('returns None when persistence succeeds', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());

      final result = await repo.remove();

      expect(result.isNone(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence fails', () async {
      when(() => persistence.remove(any())).thenAnswer(
        (_) async => const Some(PersistenceFailure.notFound()),
      );

      final result = await repo.remove();

      expect(result.isSome(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence throws', () async {
      when(() => persistence.remove(any())).thenThrow(Exception('boom'));

      final result = await repo.remove();

      expect(result.isSome(), isTrue);
    });
  });

  group('refresh', () {
    test('removes the token and returns Right(null) with no refresh token', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());

      final result = await repo.refresh();

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
      verifyNever(() => http.post(any(), data: any(named: 'data')));
    });

    test('removes the token when the refresh request fails', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());
      when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Left(
          HttpResponseError(errorType: 'http', message: 'unauthorized', statusCode: 401),
        ),
      );

      final result = await repo.refresh(refreshToken: 'ref-viejo');

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
    });

    test('returns a failure when the response body has an unexpected shape', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());
      when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Right(HttpResponse<dynamic>(data: 'no es un mapa', status: '200')),
      );

      final result = await repo.refresh(refreshToken: 'ref');

      expect(result.getOrElse(() => anAuthData()), isNull);
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test test/data/repositories/local_auth_repository_test.dart
```
Expected: PASS — 15 tests.

`refresh`'s happy path is deliberately not asserted here: it needs a `RefreshTokenModel` JSON shape read from `packages/features/auth/lib/src/data/models/refresh_token_model.dart`. Read that file and, if its `fromJson` shape is clear, add one success test asserting the returned `AuthData` carries the new token and that `persistence.set` was called. If the shape is ambiguous, say so rather than guessing at the contract.

- [ ] **Step 3: Commit**

```bash
git add packages/features/auth/test/data
git commit -m "test(auth): cobertura de LocalAuthRepository"
```

---

## Task 8: auth — AuthCubit token helpers

`decodeToken` and `isExpiredToken` are pure and need no repository interaction, so they are tested separately from the async state machine.

**Files:**
- Create: `packages/features/auth/test/presentation/bloc/auth_cubit_token_test.dart`

**Interfaces:**
- Consumes: `MockAuthRepository` defined locally in this file
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/auth/test/presentation/bloc/auth_cubit_token_test.dart`:

```dart
import 'dart:convert';

import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Arma un string con forma de JWT cuyo payload es [payload].
/// La firma no se valida, así que cualquier tercer segmento sirve.
String _jwt(Map<String, dynamic> payload) {
  final encoded = base64Url.encode(utf8.encode(json.encode(payload)));
  return 'header.$encoded.signature';
}

void main() {
  late AuthCubit cubit;

  setUp(() => cubit = AuthCubit(_MockAuthRepository()));
  tearDown(() => cubit.close());

  group('decodeToken', () {
    test('decodes the payload of a well-formed token', () {
      final decoded = cubit.decodeToken(_jwt({'sub': '123', 'role': 'admin'}));

      expect(decoded, {'sub': '123', 'role': 'admin'});
    });

    test('returns null when the token does not have three segments', () {
      expect(cubit.decodeToken('no-es-un-jwt'), isNull);
    });

    test('returns null when the payload is not valid base64', () {
      expect(cubit.decodeToken('header.!!!no-base64!!!.signature'), isNull);
    });

    test('returns null for an empty token', () {
      expect(cubit.decodeToken(''), isNull);
    });
  });

  group('isExpiredToken', () {
    test('is true for 401', () {
      expect(cubit.isExpiredToken(401, null), isTrue);
    });

    test('is false for any other status code', () {
      expect(cubit.isExpiredToken(200, null), isFalse);
      expect(cubit.isExpiredToken(403, null), isFalse);
      expect(cubit.isExpiredToken(500, 'server error'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test test/presentation/bloc/auth_cubit_token_test.dart
```
Expected: PASS — 6 tests.

- [ ] **Step 3: Commit**

```bash
git add packages/features/auth/test/presentation/bloc/auth_cubit_token_test.dart
git commit -m "test(auth): cobertura de decodeToken e isExpiredToken"
```

---

## Task 9: auth — AuthCubit load, save and reset

**`AuthCubit.load()` contains `await Future.delayed(const Duration(seconds: 1))`.** That hardcoded delay is production code, so every test exercising `load()` costs a real second of wall clock. `blocTest`'s `wait:` parameter handles it. Do **not** remove the delay to make tests faster — that changes production behaviour, and whatever splash-screen timing depends on it is outside this plan's scope. Note it in your report as a testability smell.

**Files:**
- Create: `packages/features/auth/test/presentation/bloc/auth_cubit_test.dart`

**Interfaces:**
- Consumes: `anAuthData` from Task 6
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/auth/test/presentation/bloc/auth_cubit_test.dart`:

```dart
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/auth_builders.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// `load()` tiene un `Future.delayed(Duration(seconds: 1))` hardcodeado en
/// producción, así que blocTest tiene que esperarlo de verdad.
const _loadWait = Duration(milliseconds: 1200);

void main() {
  late _MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(AuthData.empty());
  });

  setUp(() => repo = _MockAuthRepository());

  test('initial state is empty', () {
    final cubit = AuthCubit(repo);

    expect(cubit.state, const AuthState.empty());
    cubit.close();
  });

  group('load', () {
    blocTest<AuthCubit, AuthState>(
      'emits data when the repository returns a session',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => Right(anAuthData(token: 'tok'))),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [
        isA<AuthState>().having(
          (s) => s.whenOrNull(data: (d, _) => d.token),
          'token',
          'tok',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when the repository returns no session',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => const Right(null)),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [const AuthState.empty()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when the repository fails',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => Left(AuthFailure())),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [const AuthState.empty()],
    );
  });

  group('save', () {
    blocTest<AuthCubit, AuthState>(
      'emits data with hasUpdated false by default',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => const None()),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo', refreshToken: 'ref'),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.whenOrNull(data: (d, _) => d.token), 'token', 'nuevo')
            .having((s) => s.whenOrNull(data: (_, u) => u), 'hasUpdated', false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'propagates hasUpdated true',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => const None()),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo', hasUpdated: true),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.whenOrNull(data: (_, u) => u), 'hasUpdated', true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when saving fails',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => Some(AuthFailure())),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo'),
      expect: () => [const AuthState.empty()],
    );
  });

  group('reset', () {
    test('returns true and emits empty when removal succeeds', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => const None());
      final cubit = AuthCubit(repo);

      final ok = await cubit.reset();

      expect(ok, isTrue);
      expect(cubit.state, const AuthState.empty());
      await cubit.close();
    });

    test('returns false when removal fails', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => Some(AuthFailure()));
      final cubit = AuthCubit(repo);

      final ok = await cubit.reset();

      expect(ok, isFalse);
      await cubit.close();
    });

    test('blanks the stored session before removing it', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => const None());
      final cubit = AuthCubit(repo);

      await cubit.reset();

      final saved = verify(() => repo.save(captureAny())).captured.single as AuthData;
      expect(saved.token, isEmpty);
      await cubit.close();
    });
  });
}
```

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test test/presentation/bloc/auth_cubit_test.dart
```
Expected: PASS — 10 tests. The three `load` tests take about a second each because of the production delay.

- [ ] **Step 3: Commit**

```bash
git add packages/features/auth/test/presentation/bloc/auth_cubit_test.dart
git commit -m "test(auth): cobertura de load, save y reset en AuthCubit"
```

---

## Task 10: auth — AuthCubit token refresh

`onRefreshToken()` de-duplicates concurrent refreshes through a `_refreshingFuture` field: two callers hitting a 401 at the same time must produce **one** refresh call, not two. That de-duplication is the most valuable thing to pin in this package — without it, a burst of 401s produces a stampede of refresh requests.

**Files:**
- Create: `packages/features/auth/test/presentation/bloc/auth_cubit_refresh_test.dart`

**Interfaces:**
- Consumes: `anAuthData` from Task 6
- Produces: nothing new

- [ ] **Step 1: Write the test**

Create `packages/features/auth/test/presentation/bloc/auth_cubit_refresh_test.dart`:

```dart
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/auth_builders.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(AuthData.empty());
  });

  setUp(() {
    repo = _MockAuthRepository();
    when(() => repo.save(any())).thenAnswer((_) async => const None());
  });

  /// Deja el cubit en estado `data` sin pasar por `load()`, que tiene un
  /// delay de un segundo hardcodeado en producción.
  Future<AuthCubit> cubitWithSession({String? refreshToken}) async {
    final cubit = AuthCubit(repo);
    await cubit.save(token: 'tok-viejo', refreshToken: refreshToken);
    return cubit;
  }

  test('returns false when there is no session', () async {
    final cubit = AuthCubit(repo);

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns false when the session has no refresh token', () async {
    final cubit = await cubitWithSession(refreshToken: null);

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns false when the refresh token is empty', () async {
    final cubit = await cubitWithSession(refreshToken: '');

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns true and emits the renewed session on success', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async => Right(anAuthData(token: 'tok-nuevo', refreshToken: 'ref-nuevo')),
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final ok = await cubit.onRefreshToken();

    expect(ok, isTrue);
    expect(cubit.state.whenOrNull(data: (d, _) => d.token), 'tok-nuevo');
    expect(cubit.state.whenOrNull(data: (_, updated) => updated), isTrue);
    await cubit.close();
  });

  test('returns false and empties the session when refresh yields nothing', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async => const Right(null));
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final ok = await cubit.onRefreshToken();

    expect(ok, isFalse);
    expect(cubit.state, const AuthState.empty());
    await cubit.close();
  });

  test('returns false when the repository fails', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async => Left(AuthFailure()));
    when(() => repo.load()).thenAnswer((_) async => const Right(null));
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    expect(await cubit.onRefreshToken(), isFalse);
    await cubit.close();
  });

  test('two concurrent callers share a single refresh call', () async {
    var calls = 0;
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Right(anAuthData(token: 'tok-nuevo', refreshToken: 'ref-nuevo'));
      },
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final results = await Future.wait([
      cubit.onRefreshToken(),
      cubit.onRefreshToken(),
    ]);

    expect(results, [true, true]);
    expect(calls, 1, reason: 'el de-dup de _refreshingFuture debe evitar la estampida');
    await cubit.close();
  });

  test('a later refresh runs again after the first one settles', () async {
    var calls = 0;
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async {
        calls++;
        return Right(anAuthData(token: 'tok-$calls', refreshToken: 'ref-$calls'));
      },
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    await cubit.onRefreshToken();
    await cubit.onRefreshToken();

    expect(calls, 2, reason: '_refreshingFuture se limpia al terminar');
    await cubit.close();
  });
}
```

- [ ] **Step 2: Run the test**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse/packages/features/auth && flutter test test/presentation/bloc/auth_cubit_refresh_test.dart
```
Expected: PASS — 8 tests.

**If `two concurrent callers share a single refresh call` fails with `calls == 2`, that is a real bug**, not a broken test: the de-duplication is not working and a burst of 401s will stampede the refresh endpoint. Report it rather than relaxing the assertion.

- [ ] **Step 3: Commit**

```bash
git add packages/features/auth/test/presentation/bloc/auth_cubit_refresh_test.dart
git commit -m "test(auth): cobertura de refresh de token y su de-duplicacion"
```

---

## Task 11: Raise the auth floor

**Files:**
- Modify: `coverage_thresholds.yaml`

**Interfaces:**
- Consumes: Tasks 6–10
- Produces: an enforced floor for `auth`

- [ ] **Step 1: Measure**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos run test:coverage
```

- [ ] **Step 2: Set the floor**

If `auth` reached 80% or more, set `auth` `min: 80`.

If it did not, identify exactly which files and lines remain uncovered and report them. The likely gap is `mock_local_auth_repository.dart` (the in-memory demo implementation) and `auth_feature_builder.dart` (static wiring around the global `Injector`). Both are testable:
- `MockLocalAuthRepository` is a plain in-memory repo and takes the same treatment as `InMemoryCartRepository` in Task 3.
- `AuthFeatureBuilder`'s statics resolve an `AuthCubit` from `Injector.i`, so `registerMock<AuthCubit>(...)` from `test_support` controls them — the same seam `core`'s use-case tests used.

If the gap is those two files, write the tests rather than lowering the target. Report before excluding anything: exclusions are only for thin platform adapters, and neither of these is one.

Never set a floor above the measured value.

- [ ] **Step 3: Verify the gate passes**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && dart run tool/check_coverage.dart
```
Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add coverage_thresholds.yaml
git commit -m "feat(coverage): subir floor de auth"
```

---

## Task 12: Full verification

**Files:** none

- [ ] **Step 1: Clean run**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos bootstrap && melos run test:coverage
```
Expected: exit 0, every package at or above its floor.

- [ ] **Step 2: Analyze must be clean**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse && export PATH="$PATH:$HOME/.pub-cache/bin" && melos exec -- flutter analyze && flutter analyze
```
Expected: no issues in any package, including the root. A previous phase let lint errors slip past review because analyze was not part of the verification — do not repeat that.

- [ ] **Step 3: The gate must still be able to fail**

```bash
cd /home/hechicero/Documents/Prog/flutter/SmartWarehouse
python3 - <<'PY'
import re
p='coverage_thresholds.yaml'
s=open(p).read()
s=re.sub(r'(  cart:\n    path: packages/features/cart\n    min: )\d+', r'\g<1>100', s)
open(p,'w').write(s)
PY
dart run tool/check_coverage.dart; echo "exit=$?"
git checkout coverage_thresholds.yaml
```
Expected: `exit=1` with `cart` reported below floor.

- [ ] **Step 4: Push and open the PR**

```bash
git push -u origin feature/e8.2-phase2a-auth-cart
gh pr create --repo Warehouse-USAL/SmartWarehouse --base develop \
  --title "test(auth/cart): Fase 2a — builders compartidos y cobertura de auth y cart" \
  --body "Implementa la Fase 2a del spec docs/superpowers/specs/2026-08-12-test-strategy-design.md

Closes #161
Closes #162"
```

If PR #170 has not merged yet, target that branch instead of `develop` and say so in the PR body — this plan builds on tooling that only exists there.

---

## Verification Checklist

- [ ] `melos run test:coverage` exits 0 on a clean checkout after `melos bootstrap`
- [ ] `auth` and `cart` both at or above 80%, with floors set to real measurements
- [ ] No new entries in `coverage_thresholds.yaml`'s exclusion lists — pages are excluded by not being tested, not by being excluded from the denominator
- [ ] `melos exec -- flutter analyze` and root `flutter analyze` both clean
- [ ] `test_support` exports `aMoney`, `aStock`, `aProduct`, `loadJsonFixture`, `resetInjector`, `registerMock`, and the three mocks
- [ ] `test_support` depends only on `commons` and `catalog`
- [ ] The concurrent-refresh de-duplication test passes with exactly one refresh call
