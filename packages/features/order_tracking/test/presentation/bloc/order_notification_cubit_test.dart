import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_cubit.dart';
import 'package:orders/orders.dart';

import '../../support/fake_order_tracking_repository.dart';

const _change = OrderStatusChange(
  orderId: 'o-1',
  oldStatus: OrderStatus.pending,
  newStatus: OrderStatus.inProgress,
);

const _otherChange = OrderStatusChange(
  orderId: 'o-2',
  oldStatus: OrderStatus.inProgress,
  newStatus: OrderStatus.completed,
);

void main() {
  late FakeOrderTrackingRepository repo;

  setUp(() => repo = FakeOrderTrackingRepository());
  tearDown(() => repo.dispose());

  test('arranca vacio y no escucha hasta que se llama start', () async {
    final cubit = OrderNotificationCubit(repo);

    expect(cubit.state.notifications, isEmpty);
    expect(cubit.state.lastReceived, isNull);

    await cubit.close();
  });

  test('emite una notificacion por cada cambio del WS', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.notifications, hasLength(1));
    expect(cubit.state.notifications.single.change.orderId, 'o-1');
    expect(cubit.state.lastReceived, isNotNull);

    await cubit.close();
  });

  test('pone la mas nueva primero', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state.notifications.map((n) => n.change.orderId),
      ['o-2', 'o-1'],
    );

    await cubit.close();
  });

  test('invoca onEvent con el cambio recibido', () async {
    final seen = <OrderStatusChange>[];
    final cubit = OrderNotificationCubit(repo, onEvent: seen.add)..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [_change]);

    await cubit.close();
  });

  test('markAllAsRead deja unreadCount en cero', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    cubit.markAllAsRead();

    expect(cubit.state.unreadCount, 0);

    await cubit.close();
  });

  test('markAsRead marca solo la que coincide por id', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);
    repo.statusChangeController.add(_otherChange);
    await Future<void>.delayed(Duration.zero);

    final target = cubit.state.notifications.last;
    cubit.markAsRead(target.id);

    expect(cubit.state.unreadCount, 1);
    expect(
      cubit.state.notifications.firstWhere((n) => n.id == target.id).read,
      isTrue,
    );

    await cubit.close();
  });

  test('markAllAsRead limpia lastReceived para no re-disparar la SnackBar', () async {
    final cubit = OrderNotificationCubit(repo)..start();
    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    cubit.markAllAsRead();

    expect(cubit.state.lastReceived, isNull);

    await cubit.close();
  });

  test('un error del WS no rompe el cubit', () async {
    final cubit = OrderNotificationCubit(repo)..start();

    repo.statusChangeController.addError(Exception('ws caido'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.isClosed, isFalse);
    expect(cubit.state.notifications, isEmpty);

    await cubit.close();
  });

  test('start dos veces no duplica las notificaciones', () async {
    final cubit = OrderNotificationCubit(repo)
      ..start()
      ..start();

    repo.statusChangeController.add(_change);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.notifications, hasLength(1));

    await cubit.close();
  });
}
