import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/co_purchase_recommendations_repository.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';

import '../../support/fake_order_tracking_repository.dart';

Order _order(String id, List<String> productIds) => Order(
  id: id,
  items: [
    for (final pid in productIds)
      OrderItem(
        productId: pid,
        productName: pid,
        quantity: 1,
        unitPrice: const Money(amount: 0, currency: 'ARS'),
      ),
  ],
  status: OrderStatus.completed,
  createdAt: DateTime.now(),
  total: const Money(amount: 0, currency: 'ARS'),
);

void main() {
  late FakeOrderTrackingRepository orders;
  late FakeCatalogRepository catalog;
  late CoPurchaseRecommendationsRepository repo;

  final target = aProduct(id: 'cepillo', category: ProductCategory.otros);

  setUp(() {
    orders = FakeOrderTrackingRepository();
    catalog = FakeCatalogRepository();
    repo = CoPurchaseRecommendationsRepository(
      orderTrackingRepository: orders,
      catalogRepository: catalog,
    );
    // Por default el catálogo resuelve cualquier id con stock.
    catalog.onGetProductById = (id) =>
        Right(aProduct(id: id, stock: aStock(available: 5)));
    catalog.onGetProducts = () => const Right(ProductsPage.empty);
  });

  test(
    'rankea por frecuencia de co-compra y excluye el producto actual',
    () async {
      orders.onGetOrders = () => Right([
        _order('o1', ['cepillo', 'pasta']),
        _order('o2', ['cepillo', 'pasta', 'hilo']),
        _order('o3', ['cepillo', 'hilo']),
        _order('o4', ['pasta', 'jabon']), // sin cepillo: no cuenta
      ]);

      final result = await repo.recommendedFor(target);

      // pasta y hilo co-ocurren 2 veces cada uno; jabon nunca con cepillo.
      expect(result.map((p) => p.id), containsAll(['pasta', 'hilo']));
      expect(result.map((p) => p.id), isNot(contains('jabon')));
      expect(result.map((p) => p.id), isNot(contains('cepillo')));
    },
  );

  test('el mas co-comprado va primero', () async {
    orders.onGetOrders = () => Right([
      _order('o1', ['cepillo', 'pasta']),
      _order('o2', ['cepillo', 'pasta']),
      _order('o3', ['cepillo', 'hilo']),
    ]);

    final result = await repo.recommendedFor(target);

    expect(result.first.id, 'pasta');
  });

  test('un co-comprado sin stock queda afuera', () async {
    orders.onGetOrders = () => Right([
      _order('o1', ['cepillo', 'agotado']),
    ]);
    catalog.onGetProductById = (id) => Right(
      aProduct(
        id: id,
        stock: aStock(available: id == 'agotado' ? 0 : 5),
      ),
    );

    final result = await repo.recommendedFor(target);

    expect(result.where((p) => p.id == 'agotado'), isEmpty);
  });

  test(
    'sin historial cae al fallback por categoria (sin el actual ni sin stock)',
    () async {
      orders.onGetOrders = () => const Right([]);
      catalog.onGetProducts = () => Right(
        ProductsPage(
          items: [
            target, // el actual: afuera
            aProduct(id: 'vecino-1', stock: aStock(available: 3)),
            aProduct(id: 'sin-stock', stock: aStock(available: 0)),
            aProduct(id: 'vecino-2', stock: aStock(available: 1)),
          ],
          page: 1,
          pageSize: 20,
          total: 4,
          hasNext: false,
        ),
      );

      final result = await repo.recommendedFor(target);

      expect(result.map((p) => p.id), ['vecino-1', 'vecino-2']);
    },
  );

  test('la co-compra se completa con la categoria hasta el limite', () async {
    orders.onGetOrders = () => Right([
      _order('o1', ['cepillo', 'pasta']),
    ]);
    catalog.onGetProducts = () => Right(
      ProductsPage(
        items: [
          aProduct(id: 'vecino-1', stock: aStock(available: 3)),
          aProduct(id: 'pasta', stock: aStock(available: 3)), // ya incluido
        ],
        page: 1,
        pageSize: 20,
        total: 2,
        hasNext: false,
      ),
    );

    final result = await repo.recommendedFor(target, limit: 3);

    expect(result.map((p) => p.id), ['pasta', 'vecino-1']);
  });

  test('respeta el limite', () async {
    orders.onGetOrders = () => Right([
      _order('o1', ['cepillo', 'a', 'b', 'c', 'd']),
    ]);

    final result = await repo.recommendedFor(target, limit: 2);

    expect(result, hasLength(2));
  });

  test('getOrders en Left no rompe: usa solo el fallback', () async {
    orders.onGetOrders = () => const Left(OrderTrackingFailure('red caida'));
    catalog.onGetProducts = () => Right(
      ProductsPage(
        items: [aProduct(id: 'vecino-1', stock: aStock(available: 2))],
        page: 1,
        pageSize: 20,
        total: 1,
        hasNext: false,
      ),
    );

    final result = await repo.recommendedFor(target);

    expect(result.map((p) => p.id), ['vecino-1']);
  });

  test('todo caido devuelve lista vacia, nunca lanza', () async {
    orders.onGetOrders = () => const Left(OrderTrackingFailure('x'));
    catalog.onGetProducts = () => const Left(CatalogFailure('x'));

    final result = await repo.recommendedFor(target);

    expect(result, isEmpty);
  });
}
