import 'package:catalog/catalog.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';

/// Una línea lista para volver al carrito: producto fresco + cantidad ya
/// ajustada al stock actual.
typedef ReorderEntry = ({Product product, int quantity});

/// Resultado de preparar un "pedir de nuevo": qué entra al carrito, qué quedó
/// afuera y cuántas líneas se redujeron por falta de stock.
class ReorderPlan {
  const ReorderPlan({
    required this.entries,
    required this.omitted,
    required this.adjusted,
  });

  final List<ReorderEntry> entries;

  /// Nombres de los productos que quedaron afuera (sin stock o ya no están
  /// en el catálogo).
  final List<String> omitted;

  /// Cantidad de líneas cuya cantidad se redujo al máximo pedible actual.
  final int adjusted;

  bool get isEmpty => entries.isEmpty;
}

/// Prepara el repedido a partir de los items hidratados del detalle.
///
/// Reglas (las mismas que protegen el checkout):
///  - producto no hidratado (404/catálogo caído) u out of stock → afuera,
///    se reporta por nombre. Volcarlo igual agregaría una línea que bloquea
///    el checkout.
///  - cantidad pedida mayor a `maxOrderableQuantity` actual → se reduce.
ReorderPlan buildReorderPlan(List<OrderItemDetail> items) {
  final entries = <ReorderEntry>[];
  final omitted = <String>[];
  var adjusted = 0;

  for (final detail in items) {
    final product = detail.product;
    if (product == null ||
        product.stock.isOutOfStock ||
        product.maxOrderableQuantity < 1) {
      omitted.add(detail.name);
      continue;
    }
    final wanted = detail.item.quantity;
    final quantity = wanted > product.maxOrderableQuantity
        ? product.maxOrderableQuantity
        : wanted;
    if (quantity < wanted) adjusted++;
    entries.add((product: product, quantity: quantity));
  }

  return ReorderPlan(entries: entries, omitted: omitted, adjusted: adjusted);
}
