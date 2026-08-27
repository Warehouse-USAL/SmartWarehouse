import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/domain/entities/product_category.dart';
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
    ProductCategory? category,
  });

  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories();

  Future<Either<CatalogFailure, Product>> getProductById(String id);
}
