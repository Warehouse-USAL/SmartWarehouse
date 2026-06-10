import 'dart:async';

import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

class MockOrderTrackingRepository implements OrderTrackingRepository {
  final List<Order> _orders = [
    Order(
      id: 'WH-49281',
      items: [
        const OrderItem(
          productId: 'p1',
          productName: 'Heavy-duty shipping box 60×40×40',
          quantity: 8,
          unitPrice: Money(amount: 0, currency: 'ARS'),
        ),
      ],
      status: OrderStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49202',
      items: [],
      status: OrderStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49150',
      items: [],
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
    Order(
      id: 'WH-49100',
      items: [],
      status: OrderStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      total: const Money(amount: 0, currency: 'ARS'),
    ),
  ];

  final Map<String, StreamController<Order>> _controllers = {};

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    final sorted = [..._orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Right(sorted);
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async {
    try {
      final order = _orders.firstWhere((o) => o.id == id);
      return Right(order);
    } catch (_) {
      return Left(OrderTrackingFailure('Orden $id no encontrada'));
    }
  }

  @override
  Stream<Order> watchOrder(String id) {
    final controller = StreamController<Order>.broadcast();
    _controllers[id] = controller;
    final order = _orders.firstWhere(
      (o) => o.id == id,
      orElse: () => _orders.first,
    );
    Future.microtask(() {
      if (!controller.isClosed) controller.add(order);
    });
    return controller.stream;
  }

  void emitUpdate(String id, Order updated) {
    _controllers[id]?.add(updated);
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
    _controllers.clear();
  }
}
