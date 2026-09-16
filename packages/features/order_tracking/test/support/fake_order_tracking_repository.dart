import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

/// Stand-in configurable de [OrderTrackingRepository].
///
/// Es un fake con estado y no un mock de mocktail a proposito: dos de los
/// cuatro metodos devuelven `Stream`, y un test que necesita empujar eventos
/// de a uno se lee mejor con un controller expuesto que con un `when()` que
/// devuelve un stream prefabricado.
///
/// Vive en `test/support/` y no en un package compartido porque lo consume un
/// solo package (spec 4.3): la regla de >=2 cuenta packages, no archivos.
class FakeOrderTrackingRepository implements OrderTrackingRepository {
  Either<OrderTrackingFailure, List<Order>> Function() onGetOrders =
      () => const Right([]);

  Either<OrderTrackingFailure, Order> Function(String id) onGetOrderById =
      (_) => const Left(OrderTrackingFailure('not configured'));

  /// Alimenta [watchOrder]. Broadcast para que un test pueda escuchar dos
  /// veces sin que la segunda suscripcion tire.
  final orderController = StreamController<Order>.broadcast();

  /// Alimenta [watchOrderStatusChanges].
  final statusChangeController = StreamController<OrderStatusChange>.broadcast();

  /// Cuantas veces se llamo a [getOrders]. Sirve para afirmar que un refresh
  /// silencioso efectivamente re-consulto.
  int getOrdersCalls = 0;

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    getOrdersCalls++;
    return onGetOrders();
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      onGetOrderById(id);

  @override
  Stream<Order> watchOrder(String id) => orderController.stream;

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() =>
      statusChangeController.stream;

  Future<void> dispose() async {
    await orderController.close();
    await statusChangeController.close();
  }
}
