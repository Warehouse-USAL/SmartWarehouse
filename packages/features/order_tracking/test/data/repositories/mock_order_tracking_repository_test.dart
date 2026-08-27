import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
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
  });

  group('watchOrder', () {
    test('emits initial state immediately', () async {
      final listResult = await repo.getOrders();
      final firstId = listResult.fold((_) => '', (o) => o.first.id);
      final order = await repo.watchOrder(firstId).first;
      expect(order.id, firstId);
    });

    test('emits update when emitUpdate is called', () async {
      final listResult = await repo.getOrders();
      final firstOrder = listResult.fold((_) => throw Exception(), (o) => o.first);
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
