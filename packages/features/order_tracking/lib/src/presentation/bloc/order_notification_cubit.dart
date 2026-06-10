import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_notification_state.dart';

export 'order_notification_state.dart';

class OrderNotificationCubit extends Cubit<OrderNotificationState> {
  OrderNotificationCubit(this._repository) : super(const OrderNotificationIdle());

  final OrderTrackingRepository _repository;
  StreamSubscription<OrderStatusChange>? _subscription;

  void start() {
    _subscription?.cancel();
    _subscription = _repository.watchOrderStatusChanges().listen(
      (change) {
        if (!isClosed) emit(OrderNotificationReceived(change));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
