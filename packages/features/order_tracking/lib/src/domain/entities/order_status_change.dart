import 'package:orders/orders.dart';

class OrderStatusChange {
  const OrderStatusChange({
    required this.orderId,
    required this.oldStatus,
    required this.newStatus,
  });

  final String orderId;
  final OrderStatus oldStatus;
  final OrderStatus newStatus;
}
