import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_notification.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';

export 'order_notification_state.dart';

class OrderNotificationCubit extends Cubit<OrderNotificationState> {
  OrderNotificationCubit(this._repository, {this.onEvent})
      : super(const OrderNotificationState());

  final OrderTrackingRepository _repository;

  /// Callback opcional invocado en cada nuevo evento del WS — el feature
  /// builder lo usa para mostrar SnackBar via GlobalKey&lt;ScaffoldMessengerState&gt;
  /// (afuera del árbol del Navigator, así evitamos los asserts del WS+Beamer).
  final void Function(OrderStatusChange)? onEvent;

  StreamSubscription<OrderStatusChange>? _subscription;

  void start() {
    _subscription?.cancel();
    _subscription = _repository.watchOrderStatusChanges().listen(
      (change) {
        if (isClosed) return;
        final now = DateTime.now();
        final notification = OrderNotification(
          id: '${now.millisecondsSinceEpoch}-${change.orderId}',
          change: change,
          receivedAt: now,
        );
        emit(OrderNotificationState(
          notifications: [notification, ...state.notifications],
          lastReceived: notification,
        ));
        onEvent?.call(change);
      },
      onError: (Object e, StackTrace st) =>
          log('OrderNotificationCubit WS error', error: e, stackTrace: st),
    );
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(read: true)).toList();
    emit(OrderNotificationState(notifications: updated));
  }

  void markAsRead(String id) {
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(read: true) : n)
        .toList();
    emit(OrderNotificationState(notifications: updated));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
