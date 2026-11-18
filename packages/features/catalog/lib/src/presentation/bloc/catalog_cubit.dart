import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogLoading()) {
    scrollController = ScrollController()..addListener(_onScroll);
    searchController = TextEditingController();
  }

  static const _pageSize = 20;
  static const _triggerOffsetPx = 300.0;

  /// Tope de requests por carga cuando el filtro de stock deja la página
  /// corta: evita barrer todo el catálogo si casi nada tiene stock.
  static const _maxFetchesPerLoad = 5;

  final CatalogRepository _repository;
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  int _requestSeq = 0;

  String _query = '';
  ProductCategory? _category;
  List<ProductCategory> _categoriesCache = const [];

  /// Productos sin stock descartados desde el último [load]. Se descuentan
  /// del `total` del back, que los cuenta.
  int _hiddenCount = 0;

  /// Cache de categorías. Sobrevive a re-loads para que la barra de filtros
  /// siga visible aunque `state` esté en `CatalogLoading`.
  List<ProductCategory> get categories => _categoriesCache;
  ProductCategory? get selectedCategory => _category;

  Future<void> load() async {
    final seq = ++_requestSeq;
    emit(const CatalogLoading());

    if (_categoriesCache.isEmpty) {
      final categoriesResult = await _repository.getCategories();
      categoriesResult.fold((_) {}, (c) => _categoriesCache = c);
    }

    _hiddenCount = 0;
    final productsResult = await _fetchInStock(
      seq: seq,
      startPage: 1,
      pageSize: _pageSize,
    );
    if (productsResult == null) return;

    productsResult.fold(
      (failure) =>
          emit(CatalogError(failure.message ?? 'Error cargando productos')),
      (r) => emit(
        CatalogReady(
          products: r.items,
          categories: _categoriesCache,
          query: _query,
          selectedCategory: _category,
          page: r.last.page,
          pageSize: r.last.pageSize,
          total: _visibleTotal(r.last, r.items.length),
          hasNext: r.last.hasNext,
          isLoadingMore: false,
          loadMoreError: null,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final s = state;
    if (s is! CatalogReady || !s.hasNext || s.isLoadingMore) return;
    final seq = ++_requestSeq;
    emit(s.copyWith(isLoadingMore: true, loadMoreError: null));

    final result = await _fetchInStock(
      seq: seq,
      startPage: s.page + 1,
      pageSize: s.pageSize,
    );
    if (result == null) return;

    final current = state;
    if (current is! CatalogReady) return;

    result.fold(
      (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message ?? 'Error cargando más productos',
        ),
      ),
      (r) {
        final products = [...current.products, ...r.items];
        emit(
          current.copyWith(
            products: products,
            page: r.last.page,
            total: _visibleTotal(r.last, products.length),
            hasNext: r.last.hasNext,
            isLoadingMore: false,
            loadMoreError: null,
          ),
        );
      },
    );
  }

  /// Pide páginas desde [startPage] descartando los productos sin stock: el
  /// usuario nunca tiene que verlos, sea cual sea la búsqueda o categoría.
  ///
  /// Si el filtro ocultó algo y la tanda quedó por debajo de [pageSize],
  /// sigue con la página siguiente (hasta [_maxFetchesPerLoad]) para que la
  /// lista no quede corta o vacía. Si no se ocultó nada, hace un solo
  /// request, como antes del filtro.
  ///
  /// Devuelve `null` si la respuesta quedó vieja (otra carga empezó después)
  /// o el cubit se cerró. Un error en una página de relleno no descarta lo
  /// ya obtenido: se devuelve eso con `hasNext` de la última página buena.
  Future<Either<CatalogFailure, ({List<Product> items, ProductsPage last})>?>
  _fetchInStock({
    required int seq,
    required int startPage,
    required int pageSize,
  }) async {
    final items = <Product>[];
    ProductsPage? last;
    var nextPage = startPage;

    for (var fetches = 0; fetches < _maxFetchesPerLoad; fetches++) {
      final result = await _repository.getProducts(
        page: nextPage,
        pageSize: pageSize,
        search: _query.isEmpty ? null : _query,
        category: _category,
      );
      if (isClosed || seq != _requestSeq) return null;

      final failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        if (last == null) return Left(failure);
        break;
      }
      final page = result.getOrElse(() => throw StateError('unreachable'));
      last = page;

      final inStock = page.items.where((p) => !p.stock.isOutOfStock);
      final hidden = page.items.length - inStock.length;
      _hiddenCount += hidden;
      items.addAll(inStock);

      if (hidden == 0 || items.length >= pageSize || !page.hasNext) break;
      nextPage = page.page + 1;
    }
    return Right((items: items, last: last!));
  }

  /// El `total` del back cuenta los productos sin stock. Con la última
  /// página ya cargada el total visible es exacto; antes, se descuentan los
  /// ocultos vistos hasta ahora (cota superior).
  int _visibleTotal(ProductsPage last, int loaded) {
    if (!last.hasNext) return loaded;
    final t = last.total - _hiddenCount;
    return t < loaded ? loaded : t;
  }

  /// El input mantiene la query localmente pero NO dispara fetch.
  void setQuery(String q) {
    _query = q;
  }

  /// Disparado por el botón "Buscar".
  Future<void> submitSearch(String q) async {
    _query = q;
    await load();
  }

  void selectCategory(ProductCategory? category) {
    _category = category;
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
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }
}
