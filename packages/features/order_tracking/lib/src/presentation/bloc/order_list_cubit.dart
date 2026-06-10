import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';

export 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit(this._repository) : super(const OrderListLoading()) {
    scheduleMicrotask(load);
  }

  final OrderTrackingRepository _repository;

  Future<void> load() async {
    if (isClosed) return;
    emit(const OrderListLoading());
    final result = await _repository.getOrders();
    if (isClosed) return;
    result.fold(
      (failure) => emit(OrderListError(failure.message ?? 'Error desconocido')),
      (orders) => emit(OrderListReady(orders: orders)),
    );
  }

  Future<void> refresh() => load();
}
