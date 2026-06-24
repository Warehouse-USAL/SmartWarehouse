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

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    Money? total,
  }) =>
      Order(
        id: id ?? this.id,
        items: items ?? this.items,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        total: total ?? this.total,
      );
}
