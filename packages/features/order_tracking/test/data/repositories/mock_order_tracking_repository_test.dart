import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';

void main() {
  late MockOrderTrackingRepository repo;

  setUp(() => repo = MockOrderTrackingRepository());
  tearDown(() => repo.dispose());

  group('getOrders', () {
    test('returns non-empty list', () async {
      final result = await repo.getOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders, isNotEmpty));
    });

    test('returns orders sorted by createdAt descending', () async {
      final result = await repo.getOrders();
      result.fold((_) {}, (orders) {
        for (int i = 0; i < orders.length - 1; i++) {
          expect(orders[i].createdAt.isAfter(orders[i + 1].createdAt), true);
        }
      });
    });
  });

  group('getOrderById', () {
    test('returns matching order', () async {
      final listResult = await repo.getOrders();
      final firstId = listResult.fold((_) => '', (o) => o.first.id);
      final result = await repo.getOrderById(firstId);
      expect(result.isRight(), true);
      result.fold((_) {}, (order) => expect(order.id, firstId));
    });

    test('returns failure for unknown id', () async {
      final result = await repo.getOrderById('nonexistent-id');
      expect(result.isLeft(), true);
    });

    test('la cancelada de fábrica trae el código real del back', () async {
      // WH-49100 modela el caso nuevo: el back cancela por falta de stock y
      // manda el código para que la UI lo humanice en el banner.
      final result = await repo.getOrderById('WH-49100');
      result.fold((_) => fail('Expected Right'), (order) {
        expect(order.status, OrderStatus.cancelled);
        expect(order.cancelReason, 'INSUFFICIENT_STOCK');
      });
    });
  });

  group('watchOrder', () {
    test('emits initial state immediately', () async {
      final listResult = await repo.getOrders();
      final firstId = listResult.fold((_) => '', (o) => o.first.id);
      final order = await repo.watchOrder(firstId).first;
      expect(order.id, firstId);
    });

    test(
      'cancelOrder muta el estado compartido: getOrders la ve cancelada',
      () async {
        // El caso que pidió el usuario: cancelás, salís de la pantalla, volvés
        // — tiene que seguir cancelada, no "aparecer normal".
        final result = await repo.cancelOrder('WH-49281');
        result.fold((_) => fail('Expected Right'), (order) {
          expect(order.id, 'WH-49281');
          expect(order.status, OrderStatus.cancelled);
          // Cancelación manual: motivo en texto libre, distinto de los
          // códigos que decide el back.
          expect(order.cancelReason, 'Cancelada por el usuario desde la app');
        });

        final after = await repo.getOrders();
        after.fold((_) => fail('Expected Right'), (orders) {
          final cancelled = orders.firstWhere((o) => o.id == 'WH-49281');
          expect(cancelled.status, OrderStatus.cancelled);
        });

        final byId = await repo.getOrderById('WH-49281');
        byId.fold(
          (_) => fail('Expected Right'),
          (o) => expect(o.status, OrderStatus.cancelled),
        );
      },
    );

    test(
      'cancelOrder emite por watchOrder y por watchOrderStatusChanges',
      () async {
        final updates = <Order>[];
        final changes = <OrderStatusChange>[];
        final sub1 = repo.watchOrder('WH-49202').listen(updates.add);
        final sub2 = repo.watchOrderStatusChanges().listen(changes.add);
        await Future<void>.delayed(Duration.zero);

        await repo.cancelOrder('WH-49202');
        await Future<void>.delayed(Duration.zero);

        expect(updates.last.status, OrderStatus.cancelled);
        expect(changes.single.orderId, 'WH-49202');
        expect(changes.single.oldStatus, OrderStatus.pending);
        expect(changes.single.newStatus, OrderStatus.cancelled);

        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test(
      'cancelar una orden ya cancelada no re-emite cambio de estado',
      () async {
        final changes = <OrderStatusChange>[];
        final sub = repo.watchOrderStatusChanges().listen(changes.add);

        final result = await repo.cancelOrder('WH-49100');
        await Future<void>.delayed(Duration.zero);

        expect(result.isRight(), isTrue);
        expect(changes, isEmpty);
        await sub.cancel();
      },
    );

    test(
      'cancelOrder de un id desconocido devuelve Left con notFound',
      () async {
        final result = await repo.cancelOrder('WH-00000');
        result.fold(
          (failure) => expect(failure.notFound, isTrue),
          (_) => fail('Expected Left'),
        );
      },
    );

    test('emits update when emitUpdate is called', () async {
      final listResult = await repo.getOrders();
      final firstOrder = listResult.fold(
        (_) => throw Exception(),
        (o) => o.first,
      );
      final updatedOrder = Order(
        id: firstOrder.id,
        items: firstOrder.items,
        status: OrderStatus.completed,
        createdAt: firstOrder.createdAt,
        total: firstOrder.total,
      );

      final emitted = <Order>[];
      final sub = repo.watchOrder(firstOrder.id).listen(emitted.add);
      await Future<void>.delayed(Duration.zero);

      repo.emitUpdate(firstOrder.id, updatedOrder);
      await Future<void>.delayed(Duration.zero);

      await sub.cancel();
      expect(emitted.length, 2);
      expect(emitted.last.status, OrderStatus.completed);
    });
  });
}
