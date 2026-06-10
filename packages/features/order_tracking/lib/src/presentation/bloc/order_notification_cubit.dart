import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_notification.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';

export 'order_notification_state.dart';

class OrderNotificationCubit extends Cubit<OrderNotificationState> {
  OrderNotificationCubit(this._repository) : super(const OrderNotificationState());

  final OrderTrackingRepository _repository;
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
      },
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
