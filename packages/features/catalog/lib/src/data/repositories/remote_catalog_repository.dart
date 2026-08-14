import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/data/mappers/products_page_mapper.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API.
///
///   GET    /products?category=&search=&isActive=&page=&size=
///   GET    /products/{id}
///   GET    /products/categories   ← especificado en el RFC sec 3.3, pero
///                                   todavía no está implementado en el back
///                                   (a junio 2026). Si el call falla
///                                   caemos al enum local — graceful upgrade
///                                   cuando el back lo agregue.
class RemoteCatalogRepository implements CatalogRepository {
  RemoteCatalogRepository({required this.httpHelper});

  final HttpHelper httpHelper;

  @override
  Future<Either<CatalogFailure, ProductsPage>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    ProductCategory? category,
  }) async {
    try {
      final backendPage = (page - 1).clamp(0, 1 << 30);
      final query = <String, dynamic>{
        'page': backendPage,
        'size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null) 'category': category.key,
      };
      final result = await httpHelper.get('/products', queryParameters: query);
      return await result.fold(
        (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo productos')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final dto = ProductsPageDto.fromJson(data);
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('getProducts error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  /// `GET /products/categories` está definido en el RFC (sec 3.3) pero el
  /// back todavía no lo implementó. Lo intentamos igual — si falla por
  /// cualquier motivo (404, 500, red caída) hacemos fallback al enum local
  /// que de todos modos espeja el back. Así cuando el back lo agregue, el
  /// front lo consume sin más cambios.
  @override
  Future<Either<CatalogFailure, List<ProductCategory>>> getCategories() async {
    try {
      final result = await httpHelper.get('/products/categories');
      return await result.fold(
        (_) => Right(ProductCategory.values),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) return Right(ProductCategory.values);
          final raw = data['categories'];
          if (raw is! List) return Right(ProductCategory.values);
          final parsed = raw
              .whereType<String>()
              .map(ProductCategory.tryParse)
              .whereType<ProductCategory>()
              .toList(growable: false);
          // Si el back devolvió una lista vacía o todos strings desconocidos,
          // preferimos el enum local antes que dejar la UI sin filtros.
          return Right(parsed.isEmpty ? ProductCategory.values : parsed);
        },
      );
    } catch (e, st) {
      log('getCategories error (fallback to local enum)', error: e, stackTrace: st);
      return Right(ProductCategory.values);
    }
  }

  @override
  Future<Either<CatalogFailure, Product>> getProductById(String id) async {
    try {
      final result = await httpHelper.get('/products/$id');
      return await result.fold(
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
          final dto = ProductDto.fromJson(raw);
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('getProductById error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }
}
