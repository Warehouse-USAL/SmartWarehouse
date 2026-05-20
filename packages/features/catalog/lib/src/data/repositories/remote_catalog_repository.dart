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
