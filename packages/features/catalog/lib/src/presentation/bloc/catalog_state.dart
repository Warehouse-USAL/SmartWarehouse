import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_category.dart';

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
    required this.selectedCategory,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasNext,
    required this.isLoadingMore,
    required this.loadMoreError,
  });

  final List<Product> products;
  final List<ProductCategory> categories;
  final String query;
  final ProductCategory? selectedCategory;
  final int page;
  final int pageSize;
  final int total;
  final bool hasNext;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get isEmpty => products.isEmpty;

  CatalogReady copyWith({
    List<Product>? products,
    List<ProductCategory>? categories,
    String? query,
    Object? selectedCategory = _sentinel,
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
      selectedCategory: identical(selectedCategory, _sentinel)
          ? this.selectedCategory
          : selectedCategory as ProductCategory?,
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
