import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';

class OrderFailure {
  const OrderFailure([this.message]);
  final String? message;
}

abstract class OrderRepository {
  /// `POST /orders`. Envía `{ items: [{product_id, quantity}], destination: { area, address_line } }`.
  Future<Either<OrderFailure, Order>> create({
    required List<OrderItem> items,
    required OrderDestination destination,
  });

  /// `POST /orders/:id/cancel`. Envía `{ reason }`.
  Future<Either<OrderFailure, Unit>> cancel({
    required String id,
    required String reason,
  });
}
