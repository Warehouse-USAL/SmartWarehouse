import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/orders.dart';

class OrderTrackingFailure {
  const OrderTrackingFailure([this.message]);
  final String? message;
}

abstract class OrderTrackingRepository {
  /// GET /orders — lista de órdenes del usuario autenticado, ordenadas por fecha desc.
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders();

  /// GET /orders/:id — detalle completo de una orden.
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id);

  /// Stream en tiempo real de una orden vía WebSocket.
  /// Emite el estado actual via REST al suscribirse, luego emite en cada
  /// evento WS `order.updated` para el orderId dado.
  /// Reconexión con backoff exponencial ante pérdida de señal.
  Stream<Order> watchOrder(String id);
}
