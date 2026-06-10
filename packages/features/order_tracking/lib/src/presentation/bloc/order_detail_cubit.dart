import 'dart:async';

import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_state.dart';
import 'package:orders/orders.dart';

export 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit(this._repository, this._catalogRepository)
      : super(const OrderDetailLoading());

  final OrderTrackingRepository _repository;
  final CatalogRepository _catalogRepository;
  StreamSubscription<Order>? _subscription;

  // Cache local de productos hidratados (clave = productId). Persiste durante
  // toda la vida del cubit, así las actualizaciones de estado por WS no
  // disparan nuevos GET /products/{id}.
  final Map<String, Product> _productCache = {};

  void load(String orderId) {
    _subscription?.cancel();
    _productCache.clear();
    emit(const OrderDetailLoading());
    _subscription = _repository.watchOrder(orderId).listen(
      (order) async {
        if (isClosed) return;
        await _hydrateMissingProducts(order);
        if (isClosed) return;
        emit(OrderDetailReady(order: order, items: _buildItems(order)));
        if (order.status == OrderStatus.completed ||
            order.status == OrderStatus.cancelled) {
          _subscription?.cancel();
          _subscription = null;
        }
      },
      onError: (Object e) {
        if (!isClosed) emit(OrderDetailError(e.toString()));
      },
    );
  }

  /// Hace `GET /products/{id}` en paralelo por cada item que todavía no está
  /// en el cache. Los fallos individuales se ignoran — la UI usa el OrderItem
  /// puro como fallback en `OrderItemDetail`.
  Future<void> _hydrateMissingProducts(Order order) async {
    final missing = order.items
        .map((i) => i.productId)
        .where((id) => !_productCache.containsKey(id))
        .toSet()
        .toList(growable: false);
    if (missing.isEmpty) return;
    final results = await Future.wait<Either<CatalogFailure, Product>>(
      missing.map(_catalogRepository.getProductById),
    );
    for (var i = 0; i < missing.length; i++) {
      results[i].fold((_) {}, (product) => _productCache[missing[i]] = product);
    }
  }

  List<OrderItemDetail> _buildItems(Order order) => order.items
      .map((item) => OrderItemDetail(
            item: item,
            product: _productCache[item.productId],
          ))
      .toList(growable: false);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
