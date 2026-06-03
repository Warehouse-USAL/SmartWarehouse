import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API. Shape acordado con el backend
/// (ver Warehouse-USAL/wh-backend):
///
///   GET    /products?category=&search=&isActive=&page=&size=
///   GET    /products/{id}
///   GET    /categories      ← TODAVÍA NO IMPLEMENTADO en el backend.
///
/// Convenciones del backend:
/// - Paginación **0-indexed** (`page=0` es la primera).
/// - Param de tamaño se llama `size`, no `page_size`.
/// - JSON en **snake_case** (forzado por `JacksonConfig` con
///   `PropertyNamingStrategies.SNAKE_CASE`): `amount_cents`, `tax_included`,
///   `is_primary`, `max_quantity_per_order`, `order_constraints`, `created_at`,
///   etc.
/// - `category` es un string plano (slug), no un objeto `{id, name}`.
/// - No hay campo `image_url` plano: el thumb del listado se deriva de
///   `images[]` (la marcada `is_primary` o la primera).
/// - No vienen `location` ni `shipping` en el response.
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
          final list = (data['products'] as List?) ?? const [];
          final items = list
              .whereType<Map<String, dynamic>>()
              .map(_parseProduct)
              .toList(growable: false);

          final pagination = data['pagination'];
          if (pagination is Map<String, dynamic>) {
            final backendPageOut = (pagination['page'] as num?)?.toInt() ?? backendPage;
            final totalPages = (pagination['total_pages'] as num?)?.toInt() ?? 1;
            return Right(ProductsPage(
              items: items,
              page: backendPageOut + 1, // back a 1-indexed para el cubit
              pageSize: (pagination['size'] as num?)?.toInt() ?? pageSize,
              total: (pagination['total_elements'] as num?)?.toInt() ?? items.length,
              hasNext: backendPageOut + 1 < totalPages,
            ));
          }
          // Backend sin paginación — tratar como página única.
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
          return Right(_parseProduct(raw, fallbackId: id));
        },
      );
    } catch (e, st) {
      log('getProductById error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  Product _parseProduct(Map<String, dynamic> json, {String? fallbackId}) {
    final images = _parseImages(json['images']);
    // El backend no expone un `image_url` plano para el thumb del listado:
    // la primera imagen (o la marcada como primary) sirve de fallback.
    final thumbUrl = _pickThumbUrl(images);
    return Product(
      id: (json['id'] as String?) ?? fallbackId ?? '',
      sku: (json['sku'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: _parseCategory(json['category']),
      price: _parseMoney(json['price']),
      stock: _parseStock(json['stock']),
      orderConstraints: _parseOrderConstraints(json['order_constraints']),
      description: json['description'] as String?,
      imageUrl: thumbUrl,
      images: images,
      specs: _parseSpecs(json['specs']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  String? _pickThumbUrl(List<ProductImage>? images) {
    if (images == null || images.isEmpty) return null;
    final primary = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
    return primary.url.isEmpty ? null : primary.url;
  }

  /// `category` viene como String plano (slug). Si en el futuro pasa a ser
  /// objeto `{id, name}`, este parser lo tolera.
  Category _parseCategory(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Category(
        id: (raw['id'] as String?) ?? '',
        name: (raw['name'] as String?) ?? '',
      );
    }
    if (raw is String) {
      final slug = raw;
      final name = slug.isEmpty
          ? 'Otros'
          : slug[0].toUpperCase() + slug.substring(1).replaceAll('_', ' ');
      return Category(id: slug, name: name);
    }
    return const Category(id: 'other', name: 'Otros');
  }

  Money _parseMoney(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const Money(amount: 0, currency: 'ARS');
    }
    final amount = (raw['amount_cents'] as num?)?.toInt() ?? 0;
    return Money(
      amount: amount,
      currency: (raw['currency'] as String?) ?? 'ARS',
      taxIncluded: raw['tax_included'] as bool?,
    );
  }

  Stock _parseStock(dynamic raw) {
    if (raw is! Map<String, dynamic>) return Stock.empty;
    return Stock(
      available: (raw['available'] as num?)?.toInt() ?? 0,
      reserved: (raw['reserved'] as num?)?.toInt(),
      min: (raw['min'] as num?)?.toInt(),
    );
  }

  OrderConstraints _parseOrderConstraints(dynamic raw) {
    if (raw is! Map<String, dynamic>) return OrderConstraints.defaults;
    final max = (raw['max_quantity_per_order'] as num?)?.toInt() ??
        OrderConstraints.defaults.maxQuantityPerOrder;
    return OrderConstraints(maxQuantityPerOrder: max);
  }

  List<ProductImage>? _parseImages(dynamic raw) {
    if (raw is! List) return null;
    return raw
        .whereType<Map<String, dynamic>>()
        .map((j) => ProductImage(
              url: (j['url'] as String?) ?? '',
              alt: j['alt'] as String?,
              isPrimary: (j['is_primary'] as bool?) ?? false,
            ))
        .toList(growable: false);
  }

  List<Spec>? _parseSpecs(dynamic raw) {
    if (raw is! List) return null;
    return raw
        .whereType<Map<String, dynamic>>()
        .map((j) => Spec(
              label: (j['label'] as String?) ?? '',
              value: (j['value'] as String?) ?? '',
            ))
        .toList(growable: false);
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
