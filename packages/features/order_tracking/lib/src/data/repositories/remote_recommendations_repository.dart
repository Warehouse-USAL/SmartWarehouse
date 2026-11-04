import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:commons/commons.dart';
import 'package:order_tracking/src/domain/repositories/recommendations_repository.dart';

/// "Suelen llevarse juntos" contra el motor real del backend
/// (`/suggestions/v1/recommendations/cart`, release 2026-10-28): co-compra
/// por coseno + filtrado colaborativo + tendencia, calculado sobre las
/// órdenes de TODOS los usuarios — no solo las de este dispositivo.
///
/// El servicio devuelve SKUs con score; acá se resuelven a productos del
/// catálogo (para nombre, precio y stock de las cards) descartando el
/// producto actual y lo sin stock. Ante cualquier falla — servicio caído,
/// respuesta malformada, SKUs que no resuelven — cae al [fallback] local
/// (co-compra del dispositivo + misma categoría): la sección nunca rompe,
/// a lo sumo recomienda con menos señal.
class RemoteRecommendationsRepository implements RecommendationsRepository {
  RemoteRecommendationsRepository({
    required this.httpHelper,
    required this.catalogRepository,
    required this.fallback,
  });

  final HttpHelper httpHelper;
  final CatalogRepository catalogRepository;
  final RecommendationsRepository fallback;

  /// Ruta pública vía el proxy del server (Caddy rutea `/suggestions/*` al
  /// servicio). Mismo JWT del backend: lo inyectan los interceptors del
  /// HttpHelper como en cualquier otra llamada.
  static const cartPath = '/suggestions/v1/recommendations/cart';

  @override
  Future<List<Product>> recommendedFor(Product product, {int limit = 8}) async {
    try {
      final result = await httpHelper.get(
        cartPath,
        queryParameters: {'skus': product.sku, 'limit': '$limit'},
      );
      final products = await result.fold((error) async {
        log('suggestions ${error.statusCode}: ${error.message}');
        return const <Product>[];
      }, (response) => _resolveProducts(response.data, product, limit));
      if (products.isNotEmpty) return products;
      // Sin resultados útiles del motor (lista vacía, SKUs inexistentes o
      // todos sin stock): la señal local sigue siendo mejor que nada.
      return await fallback.recommendedFor(product, limit: limit);
    } catch (e, st) {
      log('recommendedFor remote error', error: e, stackTrace: st);
      return fallback.recommendedFor(product, limit: limit);
    }
  }

  Future<List<Product>> _resolveProducts(
    dynamic data,
    Product current,
    int limit,
  ) async {
    if (data is! Map<String, dynamic>) return const [];
    final recos = data['recommendations'];
    if (recos is! List) return const [];

    final out = <Product>[];
    for (final entry in recos) {
      if (out.length >= limit) break;
      if (entry is! Map) continue;
      final sku = entry['sku']?.toString();
      if (sku == null || sku.isEmpty || sku == current.sku) continue;
      final product = await _bySku(sku);
      if (product == null) continue;
      if (product.id == current.id || product.stock.isOutOfStock) continue;
      out.add(product);
    }
    return out;
  }

  /// El motor habla en SKUs; el catálogo busca por nombre o SKU con el
  /// mismo `search` del buscador. Se exige match exacto de SKU para no
  /// colar un producto cuyo nombre contenga el texto.
  Future<Product?> _bySku(String sku) async {
    final page = await catalogRepository.getProducts(search: sku, pageSize: 5);
    return page.fold((_) => null, (products) {
      for (final p in products.items) {
        if (p.sku == sku) return p;
      }
      return null;
    });
  }
}
