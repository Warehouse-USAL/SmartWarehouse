import 'dart:async';
import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orders/orders.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_state.dart';

export 'order_list_state.dart';

class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit(this._repository, this._catalogRepository)
      : super(const OrderListLoading()) {
    scheduleMicrotask(load);
    _wsSubscription = _repository.watchOrderStatusChanges().listen(
          (_) => _silentRefresh(),
          onError: (Object e, StackTrace st) =>
              log('OrderListCubit WS error', error: e, stackTrace: st),
        );
  }

  final OrderTrackingRepository _repository;
  final CatalogRepository _catalogRepository;
  StreamSubscription<OrderStatusChange>? _wsSubscription;

  // Cache global de productos compartido durante la vida del cubit. Evita
  // re-fetchear el mismo producto cada vez que aparece en una orden distinta.
  final Map<String, Product> _productCache = {};

  Future<void> load() async {
    if (isClosed) return;
    emit(const OrderListLoading());
    final result = await _repository.getOrders();
    if (isClosed) return;
    await result.fold(
      (failure) async =>
          emit(OrderListError(failure.message ?? 'Error desconocido')),
      (orders) async {
        final hydrated = await _hydrate(orders);
        if (!isClosed) emit(OrderListReady(orders: hydrated));
      },
    );
  }

  Future<void> refresh() => load();

  Future<void> silentRefresh() async {
    if (state is! OrderListReady) return load();
    return _silentRefresh();
  }

  Future<void> _silentRefresh() async {
    if (isClosed) return;
    final result = await _repository.getOrders();
    if (isClosed) return;
    await result.fold(
      (_) async {},
      (orders) async {
        final hydrated = await _hydrate(orders);
        if (!isClosed && state is OrderListReady) {
          emit(OrderListReady(orders: hydrated));
        }
      },
    );
  }

  /// El back NO devuelve precios en `OrderResponse` — los items vienen con
  /// solo `productId, sku, quantity`. Para mostrar el total real en las
  /// cards de la lista, hacemos `GET /products/{id}` por cada productId
  /// nuevo y reemplazamos `unitPrice` y `total` con los valores reales.
  /// Productos ya cacheados no se re-fetchean.
  Future<List<Order>> _hydrate(List<Order> orders) async {
    final missing = orders
        .expand((o) => o.items.map((i) => i.productId))
        .where((id) => !_productCache.containsKey(id))
        .toSet()
        .toList(growable: false);
    if (missing.isNotEmpty) {
      final results = await Future.wait<Either<CatalogFailure, Product>>(
        missing.map((id) => _catalogRepository.getProductById(id)),
      );
      for (var i = 0; i < missing.length; i++) {
        results[i].fold((_) {}, (p) => _productCache[missing[i]] = p);
      }
    }
    return orders.map(_applyPrices).toList(growable: false);
  }

  Order _applyPrices(Order order) {
    if (order.items.isEmpty) return order;
    Money? currency;
    var totalCents = 0;
    // El total solo es confiable si TODOS los items tienen producto hidratado
    // y comparten moneda; si no, lo dejamos en cero (la card muestra "—") en
    // vez de mostrar un total parcial o con moneda equivocada.
    var complete = true;
    final newItems = order.items.map((item) {
      final product = _productCache[item.productId];
      if (product == null) {
        complete = false;
        return item;
      }
      if (currency != null && product.price.currency != currency!.currency) {
        complete = false;
      }
      currency = product.price;
      totalCents += (product.price.amount * item.quantity).toInt();
      return item.copyWith(
        unitPrice: product.price,
        productName: item.productName.isEmpty ||
                item.productName == 'Producto no disponible'
            ? product.name
            : item.productName,
      );
    }).toList(growable: false);
    if (currency == null || !complete) return order.copyWith(items: newItems);
    return order.copyWith(
      items: newItems,
      total: Money(
        amount: totalCents,
        currency: currency!.currency,
        taxIncluded: currency!.taxIncluded,
      ),
    );
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
