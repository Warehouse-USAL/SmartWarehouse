import 'package:catalog/catalog.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.fromRecommendation = false,
  });

  final String productId;
  final String productName;
  final int quantity;
  final Money unitPrice;

  /// True si el ítem entró al pedido desde el carrusel de recomendaciones.
  /// Viaja al backend en el create (`items[].from_recommendation`) para
  /// medir conversión; el backend no lo devuelve, por eso el default false.
  final bool fromRecommendation;

  Money get subtotal => unitPrice * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    Money? unitPrice,
    bool? fromRecommendation,
  }) => OrderItem(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    fromRecommendation: fromRecommendation ?? this.fromRecommendation,
  );
}
