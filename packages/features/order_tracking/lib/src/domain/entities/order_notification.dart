import 'package:order_tracking/src/domain/entities/order_status_change.dart';

/// Una notificación de cambio de estado recibida por WebSocket.
class OrderNotification {
  const OrderNotification({
    required this.id,
    required this.change,
    required this.receivedAt,
    this.read = false,
  });

  /// Identificador único en memoria — combina timestamp + orderId para idempotencia.
  final String id;
  final OrderStatusChange change;
  final DateTime receivedAt;
  final bool read;

  OrderNotification copyWith({bool? read}) => OrderNotification(
        id: id,
        change: change,
        receivedAt: receivedAt,
        read: read ?? this.read,
      );
}
