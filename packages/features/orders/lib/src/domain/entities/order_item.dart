import 'package:catalog/catalog.dart';

class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final Money unitPrice;

  Money get subtotal => unitPrice * quantity;

  OrderItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    Money? unitPrice,
  }) =>
      OrderItem(
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
      );
}
