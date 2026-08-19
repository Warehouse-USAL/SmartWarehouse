import 'package:cart/cart.dart';
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id, {required int cents, required String currency}) {
  return Product(
    id: id,
    sku: 'SKU-$id',
    name: 'Producto $id',
    category: ProductCategory.otros,
    price: Money(amount: cents, currency: currency),
    stock: const Stock(available: 10, reserved: 0),
    orderConstraints: OrderConstraints.defaults,
  );
}

void main() {
  group('Cart.total', () {
    test('suma subtotales con una sola moneda', () {
      final cart = Cart(items: [
        CartItem(product: _product('a', cents: 1000, currency: 'ARS'), quantity: 2),
        CartItem(product: _product('b', cents: 500, currency: 'ARS'), quantity: 1),
      ]);
      expect(cart.hasMixedCurrencies, isFalse);
      expect(cart.total?.amount, 2500);
    });

    test('con monedas mezcladas no crashea: total null y flag activo', () {
      final cart = Cart(items: [
        CartItem(product: _product('a', cents: 1000, currency: 'ARS'), quantity: 1),
        CartItem(product: _product('b', cents: 500, currency: 'USD'), quantity: 1),
      ]);
      expect(cart.hasMixedCurrencies, isTrue);
      expect(cart.total, isNull);
    });
  });
}
