import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:catalog/src/domain/entities/products_page.dart';
import 'package:dartz/dartz.dart';

class CatalogFailure {
  const CatalogFailure([this.message, this.notFound = false]);
  final String? message;

  /// True cuando el backend respondió 404: el producto ya no existe (o fue
  /// desactivado). Distinto de un error de red, donde no se sabe nada.
  final bool notFound;
}

abstract class CatalogRepository {
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  });

  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories();

  Future<Either<CatalogFailure, Product>> getProductById(String id);
}
