import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_notification.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';
import 'package:orders/orders.dart';

OrderNotification _notification({required String id, bool read = false}) =>
    OrderNotification(
      id: id,
      change: const OrderStatusChange(
        orderId: 'o-1',
        oldStatus: OrderStatus.pending,
        newStatus: OrderStatus.inProgress,
      ),
      receivedAt: DateTime.utc(2026, 1, 1),
      read: read,
    );

void main() {
  group('OrderNotification.copyWith', () {
    test('cambia read y conserva todo lo demas', () {
      final original = _notification(id: 'n-1');

      final marked = original.copyWith(read: true);

      expect(marked.read, isTrue);
      expect(marked.id, 'n-1');
      expect(marked.change.orderId, 'o-1');
      expect(marked.receivedAt, original.receivedAt);
    });

    test('sin argumentos deja read como estaba', () {
      expect(_notification(id: 'n-1', read: true).copyWith().read, isTrue);
    });
  });

  group('OrderNotificationState.unreadCount', () {
    test('cuenta solo las no leidas', () {
      final state = OrderNotificationState(
        notifications: [
          _notification(id: 'n-1'),
          _notification(id: 'n-2', read: true),
          _notification(id: 'n-3'),
        ],
      );

      expect(state.unreadCount, 2);
    });

    test('es cero cuando no hay notificaciones', () {
      expect(const OrderNotificationState().unreadCount, 0);
    });
  });
}
