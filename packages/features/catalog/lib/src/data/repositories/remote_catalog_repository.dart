import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/data/dtos/product_dto.dart';
import 'package:catalog/src/data/dtos/products_page_dto.dart';
import 'package:catalog/src/data/mappers/product_mapper.dart';
import 'package:catalog/src/data/mappers/products_page_mapper.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API.
///
///   GET    /products?category=&search=&isActive=&page=&size=
///   GET    /products/{id}
///   GET    /categories      ← NO IMPLEMENTADO en el backend; devolvemos mock.
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
      final backendPage = (page - 1).clamp(0, 1 << 30);
      final query = <String, dynamic>{
        'page': backendPage,
        'size': pageSize,
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
          final dto = ProductsPageDto.fromJson(data);
          return Right(dto.toEntity());
        },
      );
    } catch (e, st) {
      log('getProducts error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  @override
  Future<Either<CatalogFailure, List<Category>>> getCategories() async {
    // El backend todavía no tiene `/categories`. Devolvemos una lista hardcoded
    // con los slugs que existen en los products seedeados, para que el filtro
    // de la UI funcione. Cuando el endpoint exista, reemplazar por HTTP real.
    return const Right(_mockCategories);
  }

  static const _mockCategories = [
    Category(id: 'seguridad', name: 'Seguridad'),
    Category(id: 'herramientas', name: 'Herramientas'),
    Category(id: 'almacenamiento', name: 'Almacenamiento'),
  ];

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
