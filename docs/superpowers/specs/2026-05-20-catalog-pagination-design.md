# Catalog Pagination — Design

Date: 2026-05-20
Feature package: `packages/features/catalog`
Related contract: `docs/superpowers/specs/2026-05-19-api-contracts-design.md` (`GET /products`)

## Problem

Today `CatalogCubit` calls `getProducts()` once, holds the full list in memory, and the page filters client-side. The backend now exposes pagination (`page`, `page_size`, `total`, `has_next`) and server-side filters (`search`, `category`). The catalog needs to:

1. Fetch products page-by-page from the server.
2. Drive the scroll-to-load trigger from the cubit, not the widget.
3. Render a 2-card skeleton row at the end of the grid while the next page is in flight.

## Out of scope

- `in_stock_only` filter (not exposed in the UI today).
- Pull-to-refresh.
- Caching across navigations beyond what's already retained by the existing cubit lifetime.
- Categories pagination (categories are fetched once via `GET /categories` and stay client-side).

## Architecture

```
View (CatalogPage)
  └── attaches cubit.scrollController to GridView
  └── reads state.products, state.isLoadingMore, state.loadMoreError, state.hasNext

CatalogCubit
  ├── owns ScrollController (listener fires loadMore near bottom)
  ├── owns search debounce Timer (250ms)
  ├── owns _requestSeq int (drops stale responses)
  └── calls CatalogRepository.getProducts(page, pageSize, search, categoryId)

CatalogRepository (interface)
  └── returns ProductsPage { items, page, pageSize, total, hasNext }

RemoteCatalogRepository → maps backend pagination JSON
MockCatalogRepository  → slices in-memory list, applies filters, simulates latency
```

## Domain changes

New value object:

```dart
// packages/features/catalog/lib/src/domain/entities/products_page.dart
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
}
```

Repository contract:

```dart
// packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart
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

## Data layer

### RemoteCatalogRepository

- Builds query string: `/products?page=N&page_size=20&search=...&category=...`. Omits empty params.
- Reads `data['products']` for items and `data['pagination']` for `{page, page_size, total, has_next}`.
- If `pagination` is absent (older backend behavior), falls back to `page: 1`, `pageSize: items.length`, `total: items.length`, `hasNext: false`.
- `getCategories()` still derives from a single `getProducts()` call until the new `/categories` endpoint lands; pagination params are forced to `page: 1, pageSize: 200` for this internal call so it doesn't paginate. (Acceptable interim cost; will be replaced when `/categories` is implemented.)
- Cubit caches the categories list in a `_categoriesCache` field so subsequent `load()` calls triggered by filter changes don't re-fetch categories on every keystroke debounce.

### MockCatalogRepository

- Applies `search` (name/SKU contains) and `categoryId` (exact match) to the in-memory list, then slices `[(page-1)*pageSize, page*pageSize]`.
- Returns `total` = filtered list length, `hasNext` = there are more items after the slice.
- Keeps the existing ~400ms artificial latency so the skeleton is visible during demos.

## Presentation layer

### State

```dart
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

  CatalogReady copyWith({ /* same sentinel pattern as today for nullable fields */ });
}
```

`CatalogLoading` and `CatalogError` keep their current roles (first-page only). Subsequent page failures stay inside `CatalogReady` via `loadMoreError`.

### Cubit

```dart
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

  // Filter state persists across CatalogLoading emissions so a reload
  // (search/category change → load()) keeps the user's selection.
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
    // emit CatalogReady (with _query, _categoryId, _categoriesCache) or CatalogError
  }

  Future<void> loadMore() async {
    final s = state;
    if (s is! CatalogReady || !s.hasNext || s.isLoadingMore) return;
    final seq = ++_requestSeq;
    emit(s.copyWith(isLoadingMore: true, loadMoreError: null));
    final result = await _repository.getProducts(
      page: s.page + 1,
      pageSize: s.pageSize,
      search: s.query,
      categoryId: s.selectedCategoryId,
    );
    if (seq != _requestSeq) return;
    // emit appended items + new pagination, or loadMoreError on failure
  }

  void setQuery(String q) {
    _query = q;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, load);
  }

  void selectCategory(String? id) {
    _categoryId = id;
    load(); // immediate, no debounce
  }

  void retryLoadMore() => loadMore();

  void _onScroll() {
    final s = state;
    if (s is! CatalogReady || !s.hasNext || s.isLoadingMore) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _triggerOffsetPx) loadMore();
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

Stale-response guard: every emit path checks `_requestSeq` before emitting, so a slow page-1 response can't overwrite a faster page-1 response triggered by a newer filter change.

### View

`_ReadyView` in `catalog_page.dart`:

- Reads `state.products` directly (drop client `visibleProducts`).
- `controller: widget.cubit.scrollController` on `GridView.builder`.
- `itemCount = products.length + footerSlots`, where `footerSlots = state.isLoadingMore ? 2 : (state.loadMoreError != null ? 2 : 0)`.
- For indexes `>= products.length`, render `ProductCardSkeleton` (loading) or `_LoadMoreErrorCard` (error, tap → `cubit.retryLoadMore`).
- Result count line: `${products.length} de ${state.total}` when `hasNext`, else `${state.total} resultado(s)`.

### `ProductCardSkeleton` widget

- Lives at `packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart`.
- Same outer shape as `ProductCard` (border-radius 14, padding 10, fed by the parent grid delegate so aspect ratio matches).
- Inner blocks: `Expanded` shimmer rectangle for the image area, two narrow pill shimmers for SKU + name, then a row with a wider pill + a smaller pill.
- Animation: single `AnimationController` (1.2s, reverse, repeat) interpolating between `SwColors.border` and `SwColors.surface`. No external shimmer package.

### `_LoadMoreErrorCard` widget

- Lives inside `catalog_page.dart` (private widget — small and view-only).
- Same card footprint. Renders `Icons.error_outline`, the failure message, and "Tocá para reintentar" subtext. `InkWell` → `cubit.retryLoadMore`.

## Edge cases

- **Filter change mid-loadMore:** `_requestSeq` discards the stale result; UI shows the new page-1 result.
- **`hasNext == false`:** no footer slots; the grid just ends.
- **Empty result on page 1:** existing `_EmptyView` path; `total == 0`, `hasNext == false`.
- **Cubit reuse across navigations:** `initState` still only calls `load()` if state is not `CatalogReady`. Pagination state survives a back-pop.
- **Search keystrokes:** 250ms debounce inside the cubit, no per-keystroke requests.

## Tests

Cubit-level tests (under `packages/features/catalog/test/`):

1. `load()` emits Loading → Ready with page 1, hasNext true.
2. `loadMore()` appends page 2 items and updates `page`, `hasNext`.
3. `loadMore()` is a no-op when `hasNext == false` or `isLoadingMore == true`.
4. `setQuery()` debounces and resets pagination to page 1.
5. `selectCategory()` resets pagination immediately.
6. Stale response: filter change mid-load drops the in-flight result.
7. `loadMore` failure surfaces `loadMoreError` without dropping accumulated items; `retryLoadMore()` clears it and refetches.

Repository tests:

- `MockCatalogRepository`: slicing/filter combinations, `hasNext` boundary at the last page.
- `RemoteCatalogRepository`: pagination JSON parsing, missing-pagination fallback (with mocked `HttpHelper`).

## Files touched / added

Added:
- `packages/features/catalog/lib/src/domain/entities/products_page.dart`
- `packages/features/catalog/lib/src/presentation/widgets/product_card_skeleton.dart`
- Tests as listed above.

Modified:
- `packages/features/catalog/lib/src/domain/repositories/catalog_repository.dart` — new `getProducts` signature.
- `packages/features/catalog/lib/src/data/repositories/remote_catalog_repository.dart` — query params + pagination parsing.
- `packages/features/catalog/lib/src/data/repositories/mock_catalog_repository.dart` — page slicing + filters.
- `packages/features/catalog/lib/src/presentation/bloc/catalog_cubit.dart` — pagination logic + ScrollController + debounce + stale guard.
- `packages/features/catalog/lib/src/presentation/bloc/catalog_state.dart` — new fields.
- `packages/features/catalog/lib/src/presentation/pages/catalog_page.dart` — attach controller, footer slots, skeleton/error rendering, result count text.
- `packages/features/catalog/lib/catalog.dart` — export `ProductsPage` if it's part of the public surface.
