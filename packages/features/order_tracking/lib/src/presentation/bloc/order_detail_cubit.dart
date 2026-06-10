import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_state.dart';
import 'package:orders/orders.dart';

export 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit(this._repository) : super(const OrderDetailLoading());

  final OrderTrackingRepository _repository;
  StreamSubscription<Order>? _subscription;

  void load(String orderId) {
    _subscription?.cancel();
    emit(const OrderDetailLoading());
    _subscription = _repository.watchOrder(orderId).listen(
      (order) {
        if (!isClosed) {
          emit(OrderDetailReady(order: order));
          if (order.status == OrderStatus.completed ||
              order.status == OrderStatus.cancelled) {
            _subscription?.cancel();
            _subscription = null;
          }
        }
      },
      onError: (Object e) {
        if (!isClosed) emit(OrderDetailError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
