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
}
