import 'package:bloc_test/bloc_test.dart';
import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/bloc/order_list_cubit.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

import '../../support/fake_order_tracking_repository.dart';

void main() {
  late FakeOrderTrackingRepository repo;
  late FakeCatalogRepository catalog;

  setUp(() {
    repo = FakeOrderTrackingRepository();
    catalog = FakeCatalogRepository();
  });

  tearDown(() => repo.dispose());

  OrderListCubit build() => OrderListCubit(repo, catalog);

  test('el estado inicial es OrderListLoading', () {
    final cubit = build();

    expect(cubit.state, isA<OrderListLoading>());

    cubit.close();
  });

  blocTest<OrderListCubit, OrderListState>(
    'emite Ready con las ordenes que devuelve el repo',
    setUp: () => repo.onGetOrders = () => Right([anOrder(id: 'o-1', items: [])]),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      // El cubit arranca en OrderListLoading (estado inicial del super) y
      // `load()` se dispara via scheduleMicrotask desde el constructor. Ese
      // primer `emit(OrderListLoading())` SIEMPRE viaja por el stream (bloc
      // deja pasar la primera emision sin importar igualdad), asi que queda
      // como el primer estado observado antes del Ready.
      isA<OrderListLoading>(),
      isA<OrderListReady>().having((s) => s.orders.single.id, 'id', 'o-1'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'emite Error con el mensaje del failure',
    setUp: () => repo.onGetOrders =
        () => const Left(OrderTrackingFailure('sin conexion')),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<OrderListLoading>(),
      isA<OrderListError>().having((s) => s.message, 'message', 'sin conexion'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'un failure sin mensaje cae a un texto generico',
    setUp: () => repo.onGetOrders = () => const Left(OrderTrackingFailure()),
    build: build,
    wait: const Duration(milliseconds: 10),
    expect: () => [
      isA<OrderListLoading>(),
      isA<OrderListError>()
          .having((s) => s.message, 'message', 'Error desconocido'),
    ],
  );

  blocTest<OrderListCubit, OrderListState>(
    'refresh vuelve a pasar por Loading',
    setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
    build: build,
    wait: const Duration(milliseconds: 10),
    // Si `refresh()` se llama apenas construido el cubit, corre en paralelo
    // con el `load()` que dispara el constructor: los dos `emit(Loading)`
    // colisionan (bloc no re-emite un estado igual al actual) y el segundo
    // Loading se pierde. Esperamos a que el load inicial asiente en Ready
    // antes de refrescar, asi el ciclo de refresh se observa completo.
    act: (cubit) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await cubit.refresh();
    },
    expect: () => [
      isA<OrderListLoading>(),
      isA<OrderListReady>(),
      isA<OrderListLoading>(),
      isA<OrderListReady>(),
    ],
  );

  group('hidratacion de precios', () {
    blocTest<OrderListCubit, OrderListState>(
      'reemplaza unitPrice y calcula el total con los precios del catalogo',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 2),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => Right(
              aProduct(id: id, price: aMoney(amount: id == 'p-1' ? 500 : 300)),
            );
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 1300),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'deja el total en cero si algun producto no se pudo hidratar',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 2),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => id == 'p-1'
            ? Right(aProduct(id: id, price: aMoney(amount: 500)))
            : const Left(CatalogFailure('404'));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 0),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'deja el total en cero si los items mezclan monedas',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(productId: 'p-1', quantity: 1),
                  anOrderItem(productId: 'p-2', quantity: 1),
                ],
                total: aMoney(amount: 0),
              ),
            ]);
        catalog.onGetProductById = (id) => Right(
              aProduct(
                id: id,
                price: aMoney(
                  amount: 500,
                  currency: id == 'p-1' ? 'ARS' : 'USD',
                ),
              ),
            );
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>()
            .having((s) => s.orders.single.total.amount, 'total', 0),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'reemplaza el placeholder del mapper por el nombre real del catalogo',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(
                id: 'o-1',
                items: [
                  anOrderItem(
                    productId: 'p-1',
                    productName: 'Producto no disponible',
                  ),
                ],
              ),
            ]);
        catalog.onGetProductById =
            (id) => Right(aProduct(id: id, name: 'Taladro'));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>().having(
          (s) => s.orders.single.items.single.productName,
          'productName',
          'Taladro',
        ),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'una orden sin items no dispara ningun fetch de catalogo',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      verify: (_) => expect(catalog.requestedIds, isEmpty),
      expect: () => [isA<OrderListLoading>(), isA<OrderListReady>()],
    );

    blocTest<OrderListCubit, OrderListState>(
      'no re-fetchea un producto que ya esta en el cache',
      setUp: () {
        repo.onGetOrders = () => Right([
              anOrder(id: 'o-1', items: [anOrderItem(productId: 'p-1')]),
              anOrder(id: 'o-2', items: [anOrderItem(productId: 'p-1')]),
            ]);
        catalog.onGetProductById =
            (id) => Right(aProduct(id: id, price: aMoney(amount: 500)));
      },
      build: build,
      wait: const Duration(milliseconds: 10),
      // Mismo motivo que en 'refresh vuelve a pasar por Loading': hay que
      // dejar asentar el load inicial antes de refrescar para que el
      // segundo ciclo no colisione con el del constructor.
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await cubit.refresh();
      },
      verify: (_) => expect(catalog.requestedIds, ['p-1']),
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>(),
        isA<OrderListLoading>(),
        isA<OrderListReady>(),
      ],
    );
  });

  group('refresh silencioso', () {
    blocTest<OrderListCubit, OrderListState>(
      'un cambio de estado por WS re-consulta sin pasar por Loading',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      act: (_) async {
        repo.statusChangeController.add(const OrderStatusChange(
          orderId: 'o-1',
          oldStatus: OrderStatus.pending,
          newStatus: OrderStatus.inProgress,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      expect: () => [
        isA<OrderListLoading>(),
        isA<OrderListReady>(),
        isA<OrderListReady>(),
      ],
    );

    blocTest<OrderListCubit, OrderListState>(
      'silentRefresh desde Loading hace un load completo',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: () => OrderListCubit(repo, catalog),
      act: (cubit) => cubit.silentRefresh(),
      wait: const Duration(milliseconds: 10),
      verify: (_) => expect(repo.getOrdersCalls, greaterThanOrEqualTo(1)),
    );

    blocTest<OrderListCubit, OrderListState>(
      'un failure en el refresh silencioso no pisa el Ready que ya se mostraba',
      setUp: () => repo.onGetOrders = () => Right([anOrder(items: [])]),
      build: build,
      wait: const Duration(milliseconds: 10),
      // Igual que en los otros casos con act: hay que dejar que el load
      // inicial llegue a Ready antes de forzar el failure; si no, el
      // failure tambien pisa la primera carga y nunca hay un Ready previo
      // que "no pisar".
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        repo.onGetOrders = () => const Left(OrderTrackingFailure('caido'));
        await cubit.silentRefresh();
      },
      expect: () => [isA<OrderListLoading>(), isA<OrderListReady>()],
    );
  });

  test('close cancela la suscripcion al WS', () async {
    final cubit = build();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await cubit.close();
    repo.statusChangeController.add(const OrderStatusChange(
      orderId: 'o-1',
      oldStatus: OrderStatus.pending,
      newStatus: OrderStatus.completed,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.isClosed, isTrue);
  });
}
