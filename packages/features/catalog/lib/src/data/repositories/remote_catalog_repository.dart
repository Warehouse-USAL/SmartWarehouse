import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

/// Talks to the SmartWarehouse REST API alineado al contrato
/// `docs/superpowers/specs/2026-05-19-api-contracts-design.md`:
///
///   GET /products?page=&page_size=&search=&category=
///   GET /products/{id}
///   GET /categories
///
/// JSON snake_case. Las keys del contrato se respetan literalmente (incluyendo
/// `order_constrains` con su typo y `image-url` con guion).
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
              .map(_parseListProduct)
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
    try {
      final result = await httpHelper.get('/categories');
      return result.fold(
        (error) => Left(CatalogFailure(error.message ?? 'Error obteniendo categorías')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(CatalogFailure('Respuesta inválida'));
          }
          final list = (data['categories'] as List?) ?? const [];
          return Right(
            list
                .whereType<Map<String, dynamic>>()
                .map(_parseCategory)
                .toList(growable: false),
          );
        },
      );
    } catch (e, st) {
      log('getCategories error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
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
          return Right(_parseDetailProduct(raw, fallbackId: id));
        },
      );
    } catch (e, st) {
      log('getProductById error', error: e, stackTrace: st);
      return const Left(CatalogFailure('Error de red'));
    }
  }

  Product _parseListProduct(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as String?) ?? '',
      sku: (json['sku'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: _parseCategoryFromAny(json['category']),
      price: _parseMoney(json['price']),
      stock: _parseStock(json['stock']),
      orderConstraints: _parseOrderConstraints(json['order_constrains']),
      imageUrl: (json['image-url'] as String?) ?? (json['image_url'] as String?),
      location: _parseLocation(json['location']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Product _parseDetailProduct(Map<String, dynamic> json, {required String fallbackId}) {
    return Product(
      id: (json['id'] as String?) ?? fallbackId,
      sku: (json['sku'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      category: _parseCategoryFromAny(json['category']),
      price: _parseMoney(json['price']),
      stock: _parseStock(json['stock']),
      orderConstraints: _parseOrderConstraints(json['order_constrains']),
      description: json['description'] as String?,
      images: _parseImages(json['images']),
      shipping: _parseShipping(json['shipping']),
      specs: _parseSpecs(json['specs']),
    );
  }

  Category _parseCategory(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    final name = (json['name'] as String?) ?? id;
    return Category(
      id: id,
      name: name,
      productCount: (json['product_count'] as num?)?.toInt(),
    );
  }

  Category _parseCategoryFromAny(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Category(
        id: (raw['id'] as String?) ?? '',
        name: (raw['name'] as String?) ?? '',
      );
    }
    if (raw is String) {
      // Tolerancia: si el backend manda solo un slug.
      final name = raw.isEmpty ? 'Otros' : raw[0].toUpperCase() + raw.substring(1).replaceAll('_', ' ');
      return Category(id: raw, name: name);
    }
    return const Category(id: 'other', name: 'Otros');
  }

  Money _parseMoney(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return const Money(amount: 0, currency: 'ARS');
    }
    // El contrato usa `amount` en /products y `amount_cents` en /products/{id}.
    final amount = (raw['amount'] as num?)?.toInt() ??
        (raw['amount_cents'] as num?)?.toInt() ??
        0;
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
      min: (raw['min'] as num?)?.toInt(),
      reserved: (raw['reserved'] as num?)?.toInt(),
      lowStockThreshold: (raw['low_stock_threshold'] as num?)?.toInt(),
    );
  }

  OrderConstraints _parseOrderConstraints(dynamic raw) {
    if (raw is! Map<String, dynamic>) return OrderConstraints.defaults;
    final max = (raw['max_quantity_per_order'] as num?)?.toInt() ??
        OrderConstraints.defaults.maxQuantityPerOrder;
    return OrderConstraints(maxQuantityPerOrder: max);
  }

  ProductLocation? _parseLocation(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return ProductLocation(
      idZone: (raw['id_zone'] as String?) ?? '',
      idLine: (raw['id_line'] as String?) ?? '',
      idPosition: (raw['id_position'] as String?) ?? '',
      height: (raw['height'] as String?) ?? '',
    );
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

  Shipping? _parseShipping(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return Shipping(
      shipsToday: (raw['ships_today'] as bool?) ?? false,
      cutoffTime: (raw['cutoff_time'] as String?) ?? '',
      pickupLocation: (raw['pickup_location'] as String?) ?? '',
    );
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
