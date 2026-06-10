import 'dart:async';

import 'package:catalog/catalog.dart' show Money;
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_detail_cubit.dart';
import 'package:orders/orders.dart';

class _FakeRepo implements OrderTrackingRepository {
  final Map<String, StreamController<Order>> controllers = {};

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async =>
      const Right([]);

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async =>
      const Left(OrderTrackingFailure('not used'));

  @override
  Stream<Order> watchOrder(String id) {
    final controller = StreamController<Order>.broadcast();
    controllers[id] = controller;
    return controller.stream;
  }

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() => const Stream.empty();

  void emitOrder(String id, Order order) => controllers[id]?.add(order);

  void emitError(String id, Object error) => controllers[id]?.addError(error);
}

Order _order(String id, OrderStatus status) => Order(
      id: id,
      items: [],
      status: status,
      createdAt: DateTime.now(),
      total: const Money(amount: 0, currency: 'ARS'),
    );

void main() {
  late _FakeRepo repo;
  late OrderDetailCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = OrderDetailCubit(repo);
  });

  tearDown(() => cubit.close());

  test('initial state is OrderDetailLoading', () {
    expect(cubit.state, isA<OrderDetailLoading>());
  });

  test('emits Ready when stream emits an order', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.inProgress));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.last, isA<OrderDetailReady>());
    expect((states.last as OrderDetailReady).order.status, OrderStatus.inProgress);
  });

  test('emits Ready on each update from stream', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.pending));
    await Future<void>.delayed(Duration.zero);
    repo.emitOrder('ord-1', _order('ord-1', OrderStatus.completed));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.length, 2);
    expect((states.last as OrderDetailReady).order.status, OrderStatus.completed);
  });

  test('emits Error when stream emits an error', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);

    final states = <OrderDetailState>[];
    final sub = cubit.stream.listen(states.add);

    repo.emitError('ord-1', Exception('connection lost'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.last, isA<OrderDetailError>());
  });

  test('cancels subscription on close', () async {
    cubit.load('ord-1');
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    expect(repo.controllers['ord-1']?.hasListener, isFalse);
  });
}
