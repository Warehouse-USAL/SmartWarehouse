import 'package:catalog/catalog.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
  });

  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final Money total;
}
