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

  final CatalogRepository _repository;
  late final ScrollController scrollController;
  int _requestSeq = 0;

  String _query = '';
  String? _categoryId;
  List<Category> _categoriesCache = const [];

  /// Cache de categorías. Sobrevive a re-loads para que la barra de filtros
  /// siga visible aunque `state` esté en `CatalogLoading`.
  List<Category> get categories => _categoriesCache;
  String? get selectedCategoryId => _categoryId;

  Future<void> load() async {
    final seq = ++_requestSeq;
    emit(const CatalogLoading());

    // El back todavía no expone /categories; el repo devuelve una lista
    // mockeada con los slugs del seed. Cuando exista, esto se queda igual y
    // solo cambia el repo.
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

  /// El input mantiene la query localmente pero NO dispara fetch.
  void setQuery(String q) {
    _query = q;
  }

  /// Disparado por el botón "Buscar".
  Future<void> submitSearch(String q) async {
    _query = q;
    await load();
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
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    return super.close();
  }
}
