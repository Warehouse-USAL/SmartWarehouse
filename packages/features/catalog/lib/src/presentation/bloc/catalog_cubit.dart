import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/bloc/catalog_state.dart';
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

  final CatalogRepository _repository;
  late final ScrollController scrollController;
  late final TextEditingController searchController;
  int _requestSeq = 0;

  String _query = '';
  ProductCategory? _category;
  List<ProductCategory> _categoriesCache = const [];

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

    final productsResult = await _repository.getProducts(
      page: 1,
      pageSize: _pageSize,
      search: _query.isEmpty ? null : _query,
      category: _category,
    );
    if (seq != _requestSeq) return;

    productsResult.fold(
      (failure) => emit(CatalogError(failure.message ?? 'Error cargando productos')),
      (page) => emit(CatalogReady(
        products: page.items,
        categories: _categoriesCache,
        query: _query,
        selectedCategory: _category,
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
      category: _category,
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
