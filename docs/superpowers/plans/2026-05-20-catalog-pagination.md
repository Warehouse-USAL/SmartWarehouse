# Catalog Pagination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the catalog's load-everything-once flow with server-paginated fetches, driven by a cubit-owned `ScrollController`, and render a 2-card skeleton row at the bottom of the grid while the next page loads.

**Architecture:** `CatalogRepository.getProducts` returns a `ProductsPage` (items + pagination metadata). `CatalogCubit` owns a `ScrollController` and a `_requestSeq` counter; the scroll listener triggers `loadMore()` near the bottom, filter changes reset to page 1, and stale responses are dropped. The grid renders `state.products` followed by 2 skeleton cards or an error card based on `isLoadingMore` / `loadMoreError`.

**Tech Stack:** Flutter 3.8+, `flutter_bloc` 9.1, `dartz` (Either), existing `HttpHelper` from `commons`. Tests use `flutter_test` only (no `bloc_test` to avoid adding a dependency).

**Spec:** `docs/superpowers/specs/2026-05-20-catalog-pagination-design.md`

---

## File map

Created:
- `packages/features/catalog/lib/src/domain/entities/products_page.dart`
- `packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart`
- `packages/features/catalog/test/data/mock_catalog_repository_test.dart`
- `packages/features/catalog/test/data/remote_catalog_repository_test.dart`
- `packages/features/catalog/test/presentation/bloc/catalog_cubit_test.dart`

Modified:
- `packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart`
- `packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart`
- `packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart`
- `packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart`
- `packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart`
- `packages/features/catalog/lib/src/presentation/pages/catalog_page.dart`
- `packages/features/catalog/lib/catalog.dart`

---

## Task 1: Add `ProductsPage` entity

**Files:**
- Create: `packages/features/catalog/lib/src/domain/entities/products_page.dart`

- [ ] **Step 1: Create the entity**

```dart
// packages/features/catalog/lib/src/domain/entities/products_page.dart
import 'package:catalog/src/domain/entities/product.dart';

class ProductsPage {
  const ProductsPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasNext,
  });

  final List<Product> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNext;

  static const empty = ProductsPage(
    items: [],
    page: 1,
    pageSize: 20,
    total: 0,
    hasNext: false,
  );
}
```

- [ ] **Step 2: Export from the package barrel**

Modify `packages/features/catalog/lib/catalog.dart` — add the export line so other packages can build `ProductsPage` if needed:

```dart
library catalog;

export 'src/catalog_feature_builder.dart';
export 'src/domain/entities/product.dart';
export 'src/domain/entities/category.dart';
export 'src/domain/entities/products_page.dart';
```

- [ ] **Step 3: Verify the package still analyzes**

Run: `melos exec -c 1 --scope=catalog -- dart analyze`
Expected: `No issues found!` (or at least no new issues — the existing repos still match the old signature; they'll be fixed in Task 2).

If the new file is unused yet, analyzer should be silent.

- [ ] **Step 4: Commit**

```bash
git add packages/features/catalog/lib/src/domain/entities/products_page.dart \
        packages/features/catalog/lib/catalog.dart
git commit -m "feat(catalog): add ProductsPage entity"
```

---

## Task 2: Update `CatalogRepository` contract

**Files:**
- Modify: `packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart`

This task changes the abstract contract only. The two implementations are updated in the next two tasks. Expect the package to fail to compile in between — that's fine, we commit the compiling state after Task 4.

- [ ] **Step 1: Update the interface**

Replace `packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart` entirely with:

```dart
import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:dartz/dartz.dart';

class CatalogFailure {
  const CatalogFailure([this.message]);
  final String? message;
}

abstract class CatalogRepository {
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  });

  Future<Either<CatalogFailure, List<Category>>> getCategories();

  Future<Either<CatalogFailure, Product>> getProductById(String id);
}
```

- [ ] **Step 2: Do NOT commit yet**

The two implementations are now broken; commit happens after Task 4 so each commit compiles.

---

## Task 3: Update `MockCatalogRepository`

**Files:**
- Modify: `packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart`
- Test: `packages/features/catalog/test/data/mock_catalog_repository_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `packages/features/catalog/test/data/mock_catalog_repository_test.dart`:

```dart
import 'package:catalog/src/data/repositories/mock_catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockCatalogRepository repo;

  setUp(() {
    repo = MockCatalogRepository();
  });

  group('MockCatalogRepository.getProducts', () {
    test('returns first page with pagination metadata', () async {
      final result = await repo.getProducts(page: 1, pageSize: 4);
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(4));
          expect(page.page, 1);
          expect(page.pageSize, 4);
          expect(page.total, 10);
          expect(page.hasNext, isTrue);
        },
      );
    });

    test('returns last partial page with hasNext=false', () async {
      final result = await repo.getProducts(page: 3, pageSize: 4);
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(2));
          expect(page.page, 3);
          expect(page.total, 10);
          expect(page.hasNext, isFalse);
        },
      );
    });

    test('filters by categoryId before paginating', () async {
      final result = await repo.getProducts(
        page: 1,
        pageSize: 10,
        categoryId: 'books',
      );
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(2));
          expect(page.total, 2);
          expect(page.hasNext, isFalse);
          expect(page.items.every((p) => p.category.id == 'books'), isTrue);
        },
      );
    });

    test('filters by search (case-insensitive name/SKU substring)', () async {
      final result = await repo.getProducts(
        page: 1,
        pageSize: 10,
        search: 'cafe',
      );
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(1));
          expect(page.items.first.id, 'p3');
        },
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/data/mock_catalog_repository_test.dart`
Expected: compile error — `getProducts()` signature mismatch (the old mock still has no params).

- [ ] **Step 3: Update the mock implementation**

Replace the bottom half of `packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart` (from the `@override Future<...> getProducts` onwards):

```dart
  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    Iterable<Product> filtered = _products;
    if (categoryId != null) {
      filtered = filtered.where((p) => p.category.id == categoryId);
    }
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((p) => p.matchesQuery(search));
    }
    final all = filtered.toList(growable: false);
    final total = all.length;
    final start = (page - 1) * pageSize;
    if (start >= total) {
      return Right(ProductsPage(
        items: const [],
        page: page,
        pageSize: pageSize,
        total: total,
        hasNext: false,
      ));
    }
    final end = (start + pageSize).clamp(0, total);
    final slice = all.sublist(start, end);
    return Right(ProductsPage(
      items: slice,
      page: page,
      pageSize: pageSize,
      total: total,
      hasNext: end < total,
    ));
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Right(List.unmodifiable(_categories));
  }

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final found = _products.where((p) => p.id == id);
    if (found.isEmpty) {
      return const Left(CatalogFailure('Producto no encontrado'));
    }
    return Right(found.first);
  }
}
```

Add the import at the top of the file:

```dart
import 'package:catalog/src/domain/entities/products_page.dart';
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/data/mock_catalog_repository_test.dart`
Expected: 4 tests pass.

- [ ] **Step 5: Do NOT commit yet**

`RemoteCatalogRepository` is still broken. Commit after Task 4.

---

## Task 4: Update `RemoteCatalogRepository`

**Files:**
- Modify: `packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart`
- Test: `packages/features/catalog/test/data/remote_catalog_repository_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `packages/features/catalog/test/data/remote_catalog_repository_test.dart`:

```dart
import 'package:catalog/src/data/repositories/remote_catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpHelper implements HttpHelper {
  _FakeHttpHelper(this._response);
  final Either<HttpResponseError, HttpResponse> _response;
  Map<String, dynamic>? lastQueryParams;
  String? lastPath;

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    lastPath = path;
    lastQueryParams = queryParameters;
    return _response;
  }

  // Other methods unused — throw to surface accidental calls.
  @override
  void init() {}
  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, bool retryOnTokenExpired = true, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(String path, {required Map<String, dynamic> data, required FilesData filesData, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers, bool external = false}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
}

HttpResponse _ok(Map<String, dynamic> body) =>
    HttpResponse(data: body, status: '200');

void main() {
  group('RemoteCatalogRepository.getProducts', () {
    test('passes page, page_size, search, category as query params', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': <Map<String, dynamic>>[],
        'pagination': {'page': 2, 'page_size': 20, 'total': 0, 'has_next': false},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      await repo.getProducts(page: 2, pageSize: 20, search: 'cafe', categoryId: 'home');

      expect(helper.lastPath, '/products');
      expect(helper.lastQueryParams, {
        'page': 2,
        'page_size': 20,
        'search': 'cafe',
        'category': 'home',
      });
    });

    test('omits empty/null filter params', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': <Map<String, dynamic>>[],
        'pagination': {'page': 1, 'page_size': 20, 'total': 0, 'has_next': false},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      await repo.getProducts();

      expect(helper.lastQueryParams, {'page': 1, 'page_size': 20});
    });

    test('parses items and pagination metadata', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': [
          {
            'id': 'p1',
            'sku': 'SKU-001',
            'name': 'Test',
            'category': 'electronics',
          }
        ],
        'pagination': {'page': 1, 'page_size': 20, 'total': 137, 'has_next': true},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      final result = await repo.getProducts();
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(1));
          expect(page.items.first.id, 'p1');
          expect(page.page, 1);
          expect(page.pageSize, 20);
          expect(page.total, 137);
          expect(page.hasNext, isTrue);
        },
      );
    });

    test('falls back to items.length when pagination block missing', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': [
          {'id': 'p1', 'sku': 'SKU-001', 'name': 'A', 'category': 'home'},
          {'id': 'p2', 'sku': 'SKU-002', 'name': 'B', 'category': 'home'},
        ],
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      final result = await repo.getProducts();
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(2));
          expect(page.page, 1);
          expect(page.pageSize, 2);
          expect(page.total, 2);
          expect(page.hasNext, isFalse);
        },
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/data/remote_catalog_repository_test.dart`
Expected: compile error — `getProducts()` signature mismatch.

- [ ] **Step 3: Rewrite the remote repository**

Replace `packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart` entirely with:

```dart
import 'dart:developer';

import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API:
///   GET /products?page=&page_size=&search=&category=
///   GET /products/{id}
class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository({required this.httpHelper});

  final HttpHelper httpHelper;

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      };
      final result = await httpHelper.get('/products', queryParameters: query);
      return result.fold(
        (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo productos')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final list = (data['products'] as List?) ?? const [];
          final items = list
              .whereType<Map<String, dynamic>>()
              .map(_parseProduct)
              .toList(growable: false);
          final pagination = data['pagination'];
          if (pagination is Map<String, dynamic>) {
            return Right(ProductsPage(
              items: items,
              page: (pagination['page'] as num?)?.toInt() ?? page,
              pageSize: (pagination['page_size'] as num?)?.toInt() ?? pageSize,
              total: (pagination['total'] as num?)?.toInt() ?? items.length,
              hasNext: (pagination['has_next'] as bool?) ?? false,
            ));
          }
          // Backend hasn't shipped pagination yet — treat as single page.
          return Right(ProductsPage(
            items: items,
            page: 1,
            pageSize: items.length,
            total: items.length,
            hasNext: false,
          ));
        },
      );
    } catch (e, st) {
      log('getProducts error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() async {
    // Interim: derive uniques from a single large page until /categories ships.
    final productsResult = await getProducts(page: 1, pageSize: 200);
    return productsResult.map((productsPage) {
      final seen = <String>{};
      final out = <Category>[];
      for (final p in productsPage.items) {
        if (seen.add(p.category.id)) out.add(p.category);
      }
      return out;
    });
  }

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    try {
      final result = await httpHelper.get('/products/$id');
      return result.fold(
        (error) {
          if (error.statusCode == 404) {
            return const Left(CatalogFailure('Producto no encontrado'));
          }
          return Left(CatalogFailure(error.message ?? 'Error obteniendo producto'));
        },
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final raw = data['product'];
          if (raw is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          return Right(_parseProduct(raw));
        },
      );
    } catch (e, st) {
      log('getProductById error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  Product _parseProduct(Map<String, dynamic> json) {
    final categorySlug = (json['category'] as String?) ?? 'other';
    final stockJson = json['stock'];
    final available = stockJson is Map<String, dynamic>
        ? (stockJson['available'] as num?)?.toInt()
        : null;
    return Product(
      id: (json['id'] as String?) ?? '',
      sku: (json['sku'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: _categoryFromSlug(categorySlug),
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      stock: available,
    );
  }

  Category _categoryFromSlug(String slug) {
    final name = slug.isEmpty
        ? 'Otros'
        : slug[0].toUpperCase() + slug.substring(1).replaceAll('_', ' ');
    return Category(id: slug, name: name);
  }
}
```

- [ ] **Step 4: Run tests**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/data/`
Expected: all repo tests (mock + remote) pass.

- [ ] **Step 5: Verify package compiles**

Run: `melos exec -c 1 --scope=catalog -- dart analyze`
Expected: errors limited to `catalog_cubit.dart` / `catalog_state.dart` (they still use the old single-list contract; fixed in the next task). No errors in the repos/entities.

- [ ] **Step 6: Commit**

```bash
git add packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart \
        packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart \
        packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart \
        packages/features/catalog/test/data/
git commit -m "feat(catalog): paginate repositories with ProductsPage"
```

---

## Task 5: New `CatalogState` shape

**Files:**
- Modify: `packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart`

This task only updates the state class; the cubit and view are still pointing at the old shape and will be fixed in Tasks 6 and 7. Commit happens after Task 7.

- [ ] **Step 1: Rewrite the state file**

Replace `packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart` entirely with:

```dart
import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/product.dart';

sealed class CatalogState {
  const CatalogState();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogError extends CatalogState {
  const CatalogError(this.message);
  final String message;
}

class CatalogReady extends CatalogState {
  const CatalogReady({
    required this.products,
    required this.categories,
    required this.query,
    required this.selectedCategoryId,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasNext,
    required this.isLoadingMore,
    required this.loadMoreError,
  });

  final List<Product> products;
  final List<Category> categories;
  final String query;
  final String? selectedCategoryId;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNext;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get isEmpty => products.isEmpty;

  CatalogReady copyWith({
    List<Product>? products,
    List<Category>? categories,
    String? query,
    Object? selectedCategoryId = _sentinel,
    int? page,
    int? pageSize,
    int? total,
    bool? hasNext,
    bool? isLoadingMore,
    Object? loadMoreError = _sentinel,
  }) {
    return CatalogReady(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      selectedCategoryId: identical(selectedCategoryId, _sentinel)
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: identical(loadMoreError, _sentinel)
          ? this.loadMoreError
          : loadMoreError as String?,
    );
  }
}

const Object _sentinel = Object();
```

- [ ] **Step 2: Do NOT commit yet**

Cubit and view are broken. Commit after Task 7.

---

## Task 6: Pagination cubit

**Files:**
- Modify: `packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart`
- Test: `packages/features/catalog/test/presentation/bloc/catalog_cubit_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `packages/features/catalog/test/presentation/bloc/catalog_cubit_test.dart`:

```dart
import 'dart:async';

import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements CatalogRepository {
  final List<({int page, int pageSize, String? search, String? categoryId})> calls = [];
  Future<Either<CatalogFailure, ProductsPage>> Function(int page, String? search, String? categoryId) handler =
      (page, _, __) async => Right(_emptyPage(page));
  Future<Either<CatalogFailure, List<Category>>> Function() categoriesHandler =
      () async => const Right([Category(id: 'home', name: 'Hogar')]);

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
  }) async {
    calls.add((page: page, pageSize: pageSize, search: search, categoryId: categoryId));
    return handler(page, search, categoryId);
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() => categoriesHandler();

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) =>
      throw UnimplementedError();
}

ProductsPage _emptyPage(int page) =>
    ProductsPage(items: const [], page: page, pageSize: 20, total: 0, hasNext: false);

Product _p(String id, {String category = 'home'}) => Product(
      id: id,
      sku: 'SKU-$id',
      name: 'Name $id',
      category: Category(id: category, name: category),
    );

ProductsPage _page(int page, List<Product> items, {required int total, required bool hasNext}) =>
    ProductsPage(items: items, page: page, pageSize: 20, total: total, hasNext: hasNext);

void main() {
  group('CatalogCubit.load', () {
    test('emits Loading then Ready with first page', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async =>
            Right(_page(1, [_p('1'), _p('2')], total: 30, hasNext: true));
      final cubit = CatalogCubit(repo);
      final emitted = <CatalogState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.load();
      await sub.cancel();

      expect(emitted.first, isA<CatalogLoading>());
      expect(emitted.last, isA<CatalogReady>());
      final ready = emitted.last as CatalogReady;
      expect(ready.products, hasLength(2));
      expect(ready.page, 1);
      expect(ready.total, 30);
      expect(ready.hasNext, isTrue);
      expect(ready.isLoadingMore, isFalse);
    });

    test('emits CatalogError when first-page load fails', () async {
      final repo = _FakeRepo()
        ..handler = (_, __, ___) async => const Left(CatalogFailure('boom'));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      expect(cubit.state, isA<CatalogError>());
      expect((cubit.state as CatalogError).message, 'boom');
    });
  });

  group('CatalogCubit.loadMore', () {
    test('appends next page and updates pagination', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async {
          if (page == 1) {
            return Right(_page(1, [_p('1'), _p('2')], total: 4, hasNext: true));
          }
          return Right(_page(2, [_p('3'), _p('4')], total: 4, hasNext: false));
        };
      final cubit = CatalogCubit(repo);
      await cubit.load();
      await cubit.loadMore();

      final ready = cubit.state as CatalogReady;
      expect(ready.products.map((p) => p.id), ['1', '2', '3', '4']);
      expect(ready.page, 2);
      expect(ready.hasNext, isFalse);
      expect(ready.isLoadingMore, isFalse);
    });

    test('is a no-op when hasNext is false', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async =>
            Right(_page(1, [_p('1')], total: 1, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      await cubit.loadMore();
      expect(repo.calls, isEmpty);
    });

    test('is a no-op when already loading more', () async {
      final repo = _FakeRepo();
      var firstCall = true;
      final pageCompleter = Completer<Either<CatalogFailure, ProductsPage>>();
      repo.handler = (page, _, __) async {
        if (page == 1) {
          return Right(_page(1, [_p('1')], total: 5, hasNext: true));
        }
        if (firstCall) {
          firstCall = false;
          return pageCompleter.future;
        }
        return Right(_page(2, [_p('2')], total: 5, hasNext: true));
      };
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      final first = cubit.loadMore();
      final second = cubit.loadMore(); // should be ignored
      pageCompleter.complete(Right(_page(2, [_p('2')], total: 5, hasNext: true)));
      await Future.wait([first, second]);

      expect(repo.calls.where((c) => c.page == 2), hasLength(1));
    });

    test('keeps existing items when loadMore fails and surfaces loadMoreError', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, __) async {
          if (page == 1) {
            return Right(_page(1, [_p('1')], total: 5, hasNext: true));
          }
          return const Left(CatalogFailure('net'));
        };
      final cubit = CatalogCubit(repo);
      await cubit.load();
      await cubit.loadMore();

      final ready = cubit.state as CatalogReady;
      expect(ready.products, hasLength(1));
      expect(ready.loadMoreError, 'net');
      expect(ready.isLoadingMore, isFalse);
      expect(ready.hasNext, isTrue);
    });
  });

  group('CatalogCubit filter changes', () {
    test('selectCategory resets pagination to page 1', () async {
      final repo = _FakeRepo()
        ..handler = (page, _, categoryId) async => Right(_page(
              page,
              [_p('$page', category: categoryId ?? 'home')],
              total: 5,
              hasNext: false,
            ));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.selectCategory('home');
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(repo.calls.last.page, 1);
      expect(repo.calls.last.categoryId, 'home');
    });

    test('setQuery debounces and only fires once', () async {
      final repo = _FakeRepo()
        ..handler = (page, search, _) async =>
            Right(_page(page, const [], total: 0, hasNext: false));
      final cubit = CatalogCubit(repo);
      await cubit.load();
      repo.calls.clear();

      cubit.setQuery('a');
      cubit.setQuery('ab');
      cubit.setQuery('abc');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final queryCalls = repo.calls.where((c) => c.search == 'abc');
      expect(queryCalls, hasLength(1));
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/presentation/bloc/catalog_cubit_test.dart`
Expected: compile error — current cubit doesn't have `loadMore`, fields don't match.

- [ ] **Step 3: Rewrite the cubit**

Replace `packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart` entirely with:

```dart
import 'dart:async';

import 'package:catalog/src/domain/entities/category.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogLoading()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }

  static const _pageSize = 20;
  static const _triggerOffsetPx = 300.0;
  static const _searchDebounce = Duration(milliseconds: 250);

  final CatalogRepository _repository;
  late final ScrollController scrollController;
  Timer? _searchDebounceTimer;
  int _requestSeq = 0;

  String _query = '';
  String? _categoryId;
  List<Category> _categoriesCache = const [];

  Future<void> load() async {
    final seq = ++_requestSeq;
    emit(const CatalogLoading());

    if (_categoriesCache.isEmpty) {
      final categoriesResult = await _repository.getCategories();
      categoriesResult.fold((_) {}, (c) => _categoriesCache = c);
    }

    final productsResult = await _repository.getProducts(
      page: 1,
      pageSize: _pageSize,
      search: _query.isEmpty ? null : _query,
      categoryId: _categoryId,
    );
    if (seq != _requestSeq) return;

    productsResult.fold(
      (failure) => emit(CatalogError(failure.message ?? 'Error cargando productos')),
      (page) => emit(CatalogReady(
        products: page.items,
        categories: _categoriesCache,
        query: _query,
        selectedCategoryId: _categoryId,
        page: page.page,
        pageSize: page.pageSize,
        total: page.total,
        hasNext: page.hasNext,
        isLoadingMore: false,
        loadMoreError: null,
      )),
    );
  }

  Future<void> loadMore() async {
    final s = state;
    if (s is! CatalogReady || !s.hasNext || s.isLoadingMore) return;
    final seq = ++_requestSeq;
    emit(s.copyWith(isLoadingMore: true, loadMoreError: null));

    final result = await _repository.getProducts(
      page: s.page + 1,
      pageSize: s.pageSize,
      search: _query.isEmpty ? null : _query,
      categoryId: _categoryId,
    );
    if (seq != _requestSeq) return;

    final current = state;
    if (current is! CatalogReady) return;

    result.fold(
      (failure) => emit(current.copyWith(
        isLoadingMore: false,
        loadMoreError: failure.message ?? 'Error cargando más productos',
      )),
      (page) => emit(current.copyWith(
        products: [...current.products, ...page.items],
        page: page.page,
        total: page.total,
        hasNext: page.hasNext,
        isLoadingMore: false,
        loadMoreError: null,
      )),
    );
  }

  void setQuery(String q) {
    _query = q;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, load);
  }

  void selectCategory(String? id) {
    _categoryId = id;
    load();
  }

  void retryLoadMore() => loadMore();

  void _onScroll() {
    final s = state;
    if (s is! CatalogReady || !s.hasNext || s.isLoadingMore) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _triggerOffsetPx) {
      loadMore();
    }
  }

  @override
  Future<void> close() {
    _searchDebounceTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    return super.close();
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `melos exec -c 1 --scope=catalog -- flutter test test/presentation/bloc/catalog_cubit_test.dart`
Expected: 7 tests pass.

- [ ] **Step 5: Do NOT commit yet**

`catalog_page.dart` still reads `state.allProducts` / `state.visibleProducts`. Commit after Task 7.

---

## Task 7: Skeleton widget + view wiring

**Files:**
- Create: `packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart`
- Modify: `packages/features/catalog/lib/src/presentation/pages/catalog_page.dart`

- [ ] **Step 1: Create the skeleton widget**

Create `packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart`:

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ProductCardSkeleton extends StatefulWidget {
  const ProductCardSkeleton({super.key});

  @override
  State<ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmer = Color.lerp(SwColors.border, SwColors.surface, _controller.value)!;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: SwColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _Pill(color: shimmer, width: 48, height: 8),
              const SizedBox(height: 6),
              _Pill(color: shimmer, width: 120, height: 12),
              const SizedBox(height: 6),
              _Pill(color: shimmer, width: 90, height: 12),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Pill(color: shimmer, width: 60, height: 14),
                  _Pill(color: shimmer, width: 36, height: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.width, required this.height});
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
```

- [ ] **Step 2: Update `catalog_page.dart`**

Replace `packages/features/catalog/lib/src/presentation/pages/catalog_page.dart` entirely with:

```dart
import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:catalog/src/presentation/widgets/catalog_search_bar.dart';
import 'package:catalog/src/presentation/widgets/category_filter_bar.dart';
import 'package:catalog/src/presentation/widgets/product_card.dart';
import 'package:catalog/src/presentation/widgets/product_card_skeleton.dart';
import 'package:catalog/src/presentation/widgets/sw_icon_button.dart';
import 'package:catalog/src/presentation/widgets/sw_logo_mark.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.cubit.state is! CatalogReady) {
      widget.cubit.load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar:
          BottomNavigationBarFeatureBuilder.build(context, const NavigationBarOption.products()),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CatalogAppBar(cubit: widget.cubit),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                bloc: widget.cubit,
                builder: (context, state) {
                  return switch (state) {
                    CatalogLoading() => const SwLoadingSpinner(),
                    CatalogError(:final message) =>
                        SwErrorView(message: message, onRetry: widget.cubit.load),
                    CatalogReady() => _ReadyView(
                        cubit: widget.cubit,
                        state: state,
                        searchController: _searchController,
                        onProductTap: (id) => _onProductTap(context, id),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onProductTap(BuildContext context, String productId) {
    Injector.i.resolve<NavigationHelper>().pushNamed(
          context,
          routeName: Routes.catalogDetail(productId),
        );
  }
}

class _CatalogAppBar extends StatelessWidget {
  const _CatalogAppBar({required this.cubit});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    final state = cubit.state;
    final count = state is CatalogReady ? state.total : 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SwLogoMark(size: 36),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Catálogo',
                        style: SwText.display(size: 26),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Text(
                    '$count items · Bay 14',
                    style: SwText.body(size: 13, color: SwColors.text3),
                  ),
                ),
              ],
            ),
          ),
          SwIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () {},
            badge: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: SwColors.yellowDark,
                shape: BoxShape.circle,
                border: Border.all(color: SwColors.surface, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SwIconButton(
            icon: Icons.logout,
            tooltip: 'Cerrar sesión',
            onPressed: () => AuthFeatureBuilder.logout(),
          ),
        ],
      ),
    );
  }
}

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.cubit,
    required this.state,
    required this.searchController,
    required this.onProductTap,
  });

  final CatalogCubit cubit;
  final CatalogReady state;
  final TextEditingController searchController;
  final void Function(String productId) onProductTap;

  static const _footerSlotCount = 2;

  @override
  Widget build(BuildContext context) {
    final products = state.products;
    final showSkeletons = state.isLoadingMore;
    final showErrorFooter = state.loadMoreError != null && !state.isLoadingMore;
    final footerSlots = (showSkeletons || showErrorFooter) ? _footerSlotCount : 0;
    final itemCount = products.length + footerSlots;

    final resultText = state.hasNext
        ? '${products.length} de ${state.total}'
        : '${state.total} resultado${state.total == 1 ? '' : 's'}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: CatalogSearchBar(controller: searchController, onChanged: cubit.setQuery),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: CategoryFilterBar(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            onSelected: cubit.selectCategory,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resultText,
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty && !state.isLoadingMore
              ? const _EmptyView()
              : GridView.builder(
                  controller: cubit.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      final product = products[index];
                      final tinted = index % 5 == 0;
                      return ProductCard(
                        product: product,
                        tinted: tinted,
                        onTap: () => onProductTap(product.id),
                      );
                    }
                    if (showSkeletons) {
                      return const ProductCardSkeleton();
                    }
                    return _LoadMoreErrorCard(
                      message: state.loadMoreError!,
                      onRetry: cubit.retryLoadMore,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LoadMoreErrorCard extends StatelessWidget {
  const _LoadMoreErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: SwColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: SwColors.stockOut, size: 28),
              const SizedBox(height: 8),
              Text(
                message,
                style: SwText.body(size: 12, color: SwColors.text3),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Tocá para reintentar',
                style: SwText.body(size: 11, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'No se encontraron productos.',
          style: SwText.body(size: 14, color: SwColors.text3),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analyzer is clean**

Run: `melos exec -c 1 --scope=catalog -- dart analyze`
Expected: `No issues found!`

- [ ] **Step 4: Run the whole catalog test suite**

Run: `melos exec -c 1 --scope=catalog -- flutter test`
Expected: all tests pass (mock repo, remote repo, cubit).

- [ ] **Step 5: Commit**

```bash
git add packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart \
        packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart \
        packages/features/catalog/lib/src/presentation/pages/catalog_page.dart \
        packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart \
        packages/features/catalog/test/presentation/
git commit -m "feat(catalog): paginate grid with cubit-owned scroll and skeleton footer"
```

---

## Task 8: Manual smoke test in the running app

**Files:** none

- [ ] **Step 1: Run the app against mocks**

Run: `flutter run --dart-define=USE_MOCKS=true` (or however the existing scripts launch the mock target — check `lib/main.dart` if unsure; the env toggle was introduced in commit `479e67a`).

- [ ] **Step 2: Verify behavior**

- Catalog opens, shows products from page 1.
- Scrolling to the bottom triggers the skeleton row, then page 2 appends below.
- The result count line shows `N de TOTAL` while `hasNext`, then `TOTAL resultados` at the end.
- Typing in the search bar waits ~250ms then resets to page 1.
- Tapping a category resets to page 1 immediately.
- No console errors when leaving and re-entering the catalog page.

Mock data only has 10 products so `pageSize: 20` would not paginate. For the smoke test, temporarily change `CatalogCubit._pageSize` to `4` to see the pagination flow, then revert before committing.

- [ ] **Step 3: Revert any debug change and confirm clean state**

Run: `git status`
Expected: working tree clean.

---

## Final verification

- [ ] `melos exec -c 1 --scope=catalog -- dart analyze` → no issues
- [ ] `melos exec -c 1 --scope=catalog -- flutter test` → all green
- [ ] Manual smoke test (Task 8) confirmed scroll + skeleton + filter reset
