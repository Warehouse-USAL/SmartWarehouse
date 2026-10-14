import 'package:catalog/catalog.dart';

/// Recomendaciones de productos para el detalle del catálogo.
///
/// La UI no sabe de dónde salen: hoy la implementación es co-compra sobre
/// las órdenes del dispositivo (ver CoPurchaseRecommendationsRepository);
/// cuando el algoritmo del equipo esté productivo se enchufa otra
/// implementación acá sin tocar ninguna pantalla.
abstract class RecommendationsRepository {
  /// Productos recomendados para quien está mirando [product].
  /// Nunca lanza: ante cualquier falla devuelve lista vacía (la sección
  /// simplemente no se muestra). No incluye a [product] ni productos sin
  /// stock.
  Future<List<Product>> recommendedFor(Product product, {int limit = 8});
}
