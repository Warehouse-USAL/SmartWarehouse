import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('aMoney', () {
    test('usa un default distinto de cero para no esconder bugs de suma', () {
      final money = aMoney();

      expect(money.amount, 1000);
      expect(money.currency, 'ARS');
    });

    test('respeta los overrides', () {
      final money = aMoney(amount: 250, currency: 'USD', taxIncluded: true);

      expect(money.amount, 250);
      expect(money.currency, 'USD');
      expect(money.taxIncluded, isTrue);
    });
  });

  group('aStock', () {
    test('deja el producto comprable sin estar en stock bajo', () {
      expect(aStock().available, 10);
    });

    test('respeta los overrides', () {
      expect(aStock(available: 0).available, 0);
    });
  });

  group('aProduct', () {
    test('arma un producto completo con price y stock por defecto', () {
      final product = aProduct();

      expect(product.id, 'p-1');
      expect(product.sku, 'SKU-1');
      expect(product.category, ProductCategory.herramientas);
      expect(product.price.amount, 1000);
      expect(product.stock.available, 10);
      // `orderConstraints` es no-nullable en Product: sin `?.`, que el
      // analizador marcaria como unnecessary_null_comparison.
      expect(product.orderConstraints.maxQuantityPerOrder, 5);
    });

    test('acepta price y stock explicitos', () {
      final product = aProduct(price: aMoney(amount: 5), stock: aStock(available: 1));

      expect(product.price.amount, 5);
      expect(product.stock.available, 1);
    });

    test('Product define == solo por id', () {
      expect(aProduct(id: 'x', name: 'uno'), aProduct(id: 'x', name: 'otro'));
      expect(aProduct(id: 'x'), isNot(aProduct(id: 'y')));
    });
  });
}
