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
    this.cancelReason,
  });

  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final Money total;

  /// Motivo de cancelación que informa el back (`cancel_reason`). Puede ser
  /// un código (p. ej. `INSUFFICIENT_STOCK`, ahora que el back cancela solo
  /// cuando no puede cumplir por stock) o texto libre. Solo tiene sentido
  /// cuando `status == OrderStatus.cancelled`.
  final String? cancelReason;

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    Money? total,
    String? cancelReason,
  }) => Order(
    id: id ?? this.id,
    items: items ?? this.items,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    total: total ?? this.total,
    cancelReason: cancelReason ?? this.cancelReason,
  );
}
