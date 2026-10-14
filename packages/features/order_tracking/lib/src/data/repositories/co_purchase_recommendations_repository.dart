import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/domain/repositories/recommendations_repository.dart';

/// "Suelen llevarse juntos" por co-compra: si cepillo y pasta aparecieron
/// juntos en órdenes, a quien mira el cepillo se le sugiere la pasta.
///
/// Señal: las órdenes del dispositivo (OrderTrackingRepository.getOrders).
/// Por cada orden que contiene el producto actual se suman sus compañeros,
/// ponderados por cuántas veces co-ocurrieron. Fallback: productos de la
/// misma categoría con stock, para usuarios sin historial o productos nunca
/// co-comprados. Todo se hidrata contra el catálogo para filtrar sin stock.
class CoPurchaseRecommendationsRepository implements RecommendationsRepository {
  CoPurchaseRecommendationsRepository({
    required this.orderTrackingRepository,
    required this.catalogRepository,
  });

  final OrderTrackingRepository orderTrackingRepository;
  final CatalogRepository catalogRepository;

  @override
  Future<List<Product>> recommendedFor(Product product, {int limit = 8}) async {
    try {
      final coPurchased = await _coPurchasedIds(product.id);
      final result = <Product>[];
      final seen = <String>{product.id};

      for (final id in coPurchased) {
        if (result.length >= limit) break;
        if (!seen.add(id)) continue;
        final fetched = await catalogRepository.getProductById(id);
        fetched.fold((_) {}, (p) {
          if (!p.stock.isOutOfStock) result.add(p);
        });
      }

      if (result.length < limit) {
        await _fillWithCategory(product, result, seen, limit);
      }
      return result;
    } catch (e, st) {
      log('recommendedFor error', error: e, stackTrace: st);
      return const [];
    }
  }

  /// Ids co-comprados con [productId], ordenados por frecuencia descendente.
  Future<List<String>> _coPurchasedIds(String productId) async {
    final ordersResult = await orderTrackingRepository.getOrders();
    return ordersResult.fold((_) => const [], (orders) {
      final counts = <String, int>{};
      for (final order in orders) {
        final ids = order.items.map((i) => i.productId).toSet();
        if (!ids.contains(productId)) continue;
        for (final id in ids) {
          if (id == productId) continue;
          counts[id] = (counts[id] ?? 0) + 1;
        }
      }
      final ranked = counts.keys.toList()
        ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
      return ranked;
    });
  }

  Future<void> _fillWithCategory(
    Product product,
    List<Product> result,
    Set<String> seen,
    int limit,
  ) async {
    final page = await catalogRepository.getProducts(
      category: product.category,
      pageSize: limit * 2,
    );
    page.fold((_) {}, (products) {
      for (final p in products.items) {
        if (result.length >= limit) break;
        if (!seen.add(p.id)) continue;
        if (p.stock.isOutOfStock) continue;
        result.add(p);
      }
    });
  }
}
