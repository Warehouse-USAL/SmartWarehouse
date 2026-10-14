import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';

class OrderTrackingFailure {
  const OrderTrackingFailure([this.message, this.notFound = false]);
  final String? message;

  /// True cuando el backend respondió 404: la orden ya no existe (no es un
  /// error transitorio de red) y el caller puede podarla del historial.
  final bool notFound;
}

abstract class OrderTrackingRepository {
  /// GET /orders — lista de órdenes del usuario autenticado, ordenadas por fecha desc.
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders();

  /// GET /orders/:id — detalle completo de una orden.
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id);

  /// POST /orders/:id/cancel — cancela la orden y devuelve su versión
  /// actualizada (status cancelled). El mock muta el estado compartido y
  /// emite por los streams: salir del detalle y volver sigue mostrando la
  /// orden cancelada.
  Future<Either<OrderTrackingFailure, Order>> cancelOrder(String id);

  /// Stream en tiempo real de una orden vía WebSocket.
  /// Emite el estado actual via REST al suscribirse, luego emite en cada
  /// evento WS `order.updated` para el orderId dado.
  /// Reconexión con backoff exponencial ante pérdida de señal.
  Stream<Order> watchOrder(String id);

  /// Stream de cambios de estado en CUALQUIER orden del usuario autenticado.
  /// Emite [OrderStatusChange] sólo cuando el estado de una orden cambia
  /// respecto al último valor conocido. Siembra el caché vía REST al inicio.
  Stream<OrderStatusChange> watchOrderStatusChanges();
}
