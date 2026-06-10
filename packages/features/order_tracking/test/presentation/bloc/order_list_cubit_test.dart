import 'dart:async';

import 'package:catalog/catalog.dart' show Money;
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:orders/orders.dart';

class _FakeRepo implements OrderTrackingRepository {
  Either<OrderTrackingFailure, List<Order>> result =
      const Right([]);

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async => result;

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      const Left(OrderTrackingFailure('not used'));

  @override
  Stream<Order> watchOrder(String id) => const Stream.empty();

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() => const Stream.empty();
}

Order _order(String id) => Order(
      id: id,
      items: [],
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      total: const Money(amount: 0, currency: 'ARS'),
    );

void main() {
  late _FakeRepo repo;

  setUp(() => repo = _FakeRepo());

  test('initial state is OrderListLoading', () {
    repo.result = const Right([]);
    final cubit = OrderListCubit(repo);
    expect(cubit.state, isA<OrderListLoading>());
    cubit.close();
  });

  test('emits Loading then Ready with orders', () async {
    repo.result = Right([_order('o1'), _order('o2')]);
    final cubit = OrderListCubit(repo);
    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();

    expect(states.first, isA<OrderListLoading>());
    expect(states.last, isA<OrderListReady>());
    final ready = states.last as OrderListReady;
    expect(ready.orders.length, 2);
  });

  test('emits Error when repository returns failure', () async {
    repo.result =
        const Left(OrderTrackingFailure('Error de red'));
    final cubit = OrderListCubit(repo);
    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);

    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();

    expect(states.last, isA<OrderListError>());
    expect((states.last as OrderListError).message, 'Error de red');
  });

  test('refresh re-emits Loading then Ready', () async {
    repo.result = Right([_order('o1')]);
    final cubit = OrderListCubit(repo);
    await Future<void>.delayed(Duration.zero);

    final states = <OrderListState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.refresh();
    await sub.cancel();
    await cubit.close();

    expect(states.first, isA<OrderListLoading>());
    expect(states.last, isA<OrderListReady>());
  });
}
