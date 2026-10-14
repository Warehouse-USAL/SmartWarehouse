import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:order_tracking/src/domain/entities/reorder_plan.dart';
import 'package:orders/orders.dart';

OrderItem _item(String productId, int quantity) => OrderItem(
  productId: productId,
  productName: 'Nombre de $productId',
  quantity: quantity,
  unitPrice: const Money(amount: 0, currency: 'ARS'),
);

void main() {
  test('todos disponibles: entran con su cantidad original', () {
    final plan = buildReorderPlan([
      OrderItemDetail(
        item: _item('p1', 2),
        product: aProduct(id: 'p1', stock: aStock(available: 10)),
      ),
      OrderItemDetail(
        item: _item('p2', 1),
        product: aProduct(id: 'p2', stock: aStock(available: 5)),
      ),
    ]);

    expect(plan.entries, hasLength(2));
    expect(plan.entries[0].quantity, 2);
    expect(plan.entries[1].quantity, 1);
    expect(plan.omitted, isEmpty);
    expect(plan.adjusted, 0);
    expect(plan.isEmpty, isFalse);
  });

  test(
    'producto no hidratado (404/catalogo caido) queda afuera con nombre',
    () {
      final plan = buildReorderPlan([
        OrderItemDetail(item: _item('gone', 3)),
        OrderItemDetail(
          item: _item('p1', 1),
          product: aProduct(id: 'p1', stock: aStock(available: 4)),
        ),
      ]);

      expect(plan.entries, hasLength(1));
      expect(plan.omitted, ['Nombre de gone']);
    },
  );

  test('producto sin stock queda afuera', () {
    final plan = buildReorderPlan([
      OrderItemDetail(
        item: _item('p3', 2),
        product: aProduct(
          id: 'p3',
          name: 'Teclado',
          stock: aStock(available: 0),
        ),
      ),
    ]);

    expect(plan.entries, isEmpty);
    expect(plan.isEmpty, isTrue);
    expect(plan.omitted, ['Teclado']);
  });

  test(
    'cantidad mayor al maximo pedible se reduce y se cuenta en adjusted',
    () {
      // maxOrderableQuantity = min(stock.available, maxQuantityPerOrder=5)
      final plan = buildReorderPlan([
        OrderItemDetail(
          item: _item('p2', 8),
          product: aProduct(id: 'p2', stock: aStock(available: 3)),
        ),
      ]);

      expect(plan.entries.single.quantity, 3);
      expect(plan.adjusted, 1);
      expect(plan.omitted, isEmpty);
    },
  );

  test('el limite por orden tambien clampea aunque haya stock de sobra', () {
    // El builder arma orderConstraints con maxQuantityPerOrder: 5.
    final plan = buildReorderPlan([
      OrderItemDetail(
        item: _item('p1', 9),
        product: aProduct(id: 'p1', stock: aStock(available: 100)),
      ),
    ]);

    expect(plan.entries.single.quantity, 5);
    expect(plan.adjusted, 1);
  });

  test('lista vacia produce plan vacio', () {
    final plan = buildReorderPlan(const []);
    expect(plan.isEmpty, isTrue);
    expect(plan.omitted, isEmpty);
    expect(plan.adjusted, 0);
  });
}
