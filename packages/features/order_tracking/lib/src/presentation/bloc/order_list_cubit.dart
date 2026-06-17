import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';

export 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit(this._repository) : super(const OrderListLoading()) {
    scheduleMicrotask(load);
    // Auto-refresh cuando llega cambio de status por WS — sin re-emitir
    // loading: pisa la lista existente con los nuevos status detrás de
    // escena para que la UI no flicker.
    _wsSubscription =
        _repository.watchOrderStatusChanges().listen((_) => _silentRefresh());
  }

  final OrderTrackingRepository _repository;
  StreamSubscription<OrderStatusChange>? _wsSubscription;

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

  /// Re-fetcha sin pasar por loading: solo actualiza el Ready si ya estábamos
  /// listos. Lo usamos cuando llega un event del WS — el usuario no necesita
  /// ver el spinner por un cambio de status remoto.
  Future<void> _silentRefresh() async {
    if (isClosed) return;
    final result = await _repository.getOrders();
    if (isClosed) return;
    result.fold(
      (_) {}, // No reemplazamos el estado actual si falla — preferimos
              // mantener la lista vieja vs mostrar error por un blip de red.
      (orders) {
        if (state is OrderListReady) {
          emit(OrderListReady(orders: orders));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
