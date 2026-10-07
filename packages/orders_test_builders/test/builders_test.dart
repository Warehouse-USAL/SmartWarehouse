import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

void main() {
  group('anOrderItem', () {
    test('usa una cantidad distinta de uno para no esconder bugs de multiplicacion', () {
      final item = anOrderItem();

      expect(item.quantity, 2);
      expect(item.unitPrice, aMoney());
      expect(item.subtotal.amount, 2000);
    });

    test('respeta los overrides', () {
      final item = anOrderItem(
        productId: 'p-9',
        productName: 'Taladro',
        quantity: 5,
        unitPrice: aMoney(amount: 300),
      );

      expect(item.productId, 'p-9');
      expect(item.productName, 'Taladro');
      expect(item.quantity, 5);
      expect(item.subtotal.amount, 1500);
    });
  });

  group('anOrder', () {
    test('arma una orden completa con un item por defecto', () {
      final order = anOrder();

      expect(order.id, 'o-1');
      expect(order.items, hasLength(1));
      expect(order.status, OrderStatus.pending);
    });

    test('deriva el total de los subtotales de los items', () {
      final order = anOrder(
        items: [
          anOrderItem(quantity: 1, unitPrice: aMoney(amount: 500)),
          anOrderItem(quantity: 3, unitPrice: aMoney(amount: 200)),
        ],
      );

      expect(order.total.amount, 1100);
    });

    test('respeta un total explicito aunque no cierre con los items', () {
      final order = anOrder(
        items: [anOrderItem(quantity: 1, unitPrice: aMoney(amount: 500))],
        total: aMoney(amount: 99),
      );

      expect(order.total.amount, 99);
    });

    test('da total cero cuando no hay items', () {
      expect(anOrder(items: []).total, Money.zero('ARS'));
    });

    test('usa una fecha fija en UTC para que los tests sean deterministas', () {
      expect(anOrder().createdAt, DateTime.utc(2026, 1, 1));
      expect(anOrder().createdAt, anOrder().createdAt);
    });
  });

  group('anOrderDestination', () {
    test('usa los defaults del contrato', () {
      final destination = anOrderDestination();

      expect(destination.area, OrderDestination.defaults.area);
      expect(destination.street, OrderDestination.defaults.street);
      expect(destination.postalCode, OrderDestination.defaults.postalCode);
    });

    test('permite setear los opcionales que OrderDestination.defaults no cubre', () {
      final destination = anOrderDestination(department: 'B', floor: '3');

      expect(destination.department, 'B');
      expect(destination.floor, '3');
    });
  });
}
