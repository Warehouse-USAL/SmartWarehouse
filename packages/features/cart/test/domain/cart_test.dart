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

  group('Cart.hasInvalidQuantities', () {
    Cart cartWith({required int quantity, required int available}) {
      final product = Product(
        id: 'p1',
        sku: 'SKU-p1',
        name: 'Producto p1',
        category: ProductCategory.otros,
        price: const Money(amount: 1000, currency: 'ARS'),
        stock: Stock(available: available, reserved: 0),
        orderConstraints: OrderConstraints.defaults,
      );
      return Cart(items: [CartItem(product: product, quantity: quantity)]);
    }

    test('carrito vacío no tiene cantidades inválidas', () {
      expect(Cart.empty().hasInvalidQuantities, isFalse);
    });

    test('cantidad 0 es inválida', () {
      expect(cartWith(quantity: 0, available: 10).hasInvalidQuantities, isTrue);
    });

    test('cantidad negativa es inválida', () {
      expect(cartWith(quantity: -1, available: 10).hasInvalidQuantities, isTrue);
    });

    test('cantidad igual al stock disponible es válida (borde)', () {
      expect(cartWith(quantity: 10, available: 10).hasInvalidQuantities, isFalse);
    });

    test('cantidad mayor al stock disponible es inválida (sobreventa)', () {
      expect(cartWith(quantity: 11, available: 10).hasInvalidQuantities, isTrue);
    });

    test('un solo item inválido alcanza para invalidar el carrito', () {
      final ok = _product('a', cents: 1000, currency: 'ARS');
      final sinStock = Product(
        id: 'b',
        sku: 'SKU-b',
        name: 'Producto b',
        category: ProductCategory.otros,
        price: const Money(amount: 500, currency: 'ARS'),
        stock: const Stock(available: 1, reserved: 0),
        orderConstraints: OrderConstraints.defaults,
      );
      final cart = Cart(items: [
        CartItem(product: ok, quantity: 1),
        CartItem(product: sinStock, quantity: 2),
      ]);
      expect(cart.hasInvalidQuantities, isTrue);
    });
  });
}
