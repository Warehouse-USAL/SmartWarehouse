import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

void main() {
  group('CartItem', () {
    test('subtotal multiplies the unit price by the quantity', () {
      final item = CartItem(
        product: aProduct(price: aMoney(amount: 2500)),
        quantity: 3,
      );

      expect(item.subtotal, aMoney(amount: 7500));
    });

    test('subtotal of a single unit equals the unit price', () {
      final item = CartItem(
        product: aProduct(price: aMoney(amount: 999)),
        quantity: 1,
      );

      expect(item.subtotal, aMoney(amount: 999));
    });

    test('copyWith replaces the quantity and keeps the product', () {
      final product = aProduct(id: 'p-9');
      final item = CartItem(product: product, quantity: 1);

      final updated = item.copyWith(quantity: 4);

      expect(updated.quantity, 4);
      expect(updated.product.id, 'p-9');
    });

    test('copyWith with no argument keeps the quantity', () {
      final item = CartItem(product: aProduct(), quantity: 2);

      expect(item.copyWith().quantity, 2);
    });
  });

  group('Cart.empty', () {
    test('has no items and reports empty', () {
      final cart = Cart.empty();

      expect(cart.items, isEmpty);
      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
      expect(cart.itemCount, 0);
    });

    test('total is null when there is no currency of reference', () {
      expect(Cart.empty().total, isNull);
    });
  });

  group('Cart.itemCount', () {
    test('sums quantities rather than counting lines', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'a'), quantity: 2),
        CartItem(product: aProduct(id: 'b'), quantity: 3),
      ]);

      expect(cart.itemCount, 5);
    });
  });

  group('Cart.total', () {
    test('sums the subtotals of every line', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'a', price: aMoney(amount: 1000)), quantity: 2),
        CartItem(product: aProduct(id: 'b', price: aMoney(amount: 500)), quantity: 1),
      ]);

      expect(cart.total, aMoney(amount: 2500));
    });

    test('keeps the currency of the first item', () {
      final cart = Cart(items: [
        CartItem(
          product: aProduct(price: aMoney(amount: 100, currency: 'USD')),
          quantity: 1,
        ),
      ]);

      expect(cart.total?.currency, 'USD');
    });

    test('throws when the cart mixes currencies', () {
      final cart = Cart(items: [
        CartItem(
          product: aProduct(id: 'a', price: aMoney(amount: 100, currency: 'ARS')),
          quantity: 1,
        ),
        CartItem(
          product: aProduct(id: 'b', price: aMoney(amount: 100, currency: 'USD')),
          quantity: 1,
        ),
      ]);

      expect(() => cart.total, throwsArgumentError);
    });
  });

  group('Cart.quantityOf', () {
    test('returns the quantity of a product in the cart', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'p-7'), quantity: 3),
      ]);

      expect(cart.quantityOf('p-7'), 3);
    });

    test('returns zero for a product that is not in the cart', () {
      final cart = Cart(items: [
        CartItem(product: aProduct(id: 'p-7'), quantity: 3),
      ]);

      expect(cart.quantityOf('p-otro'), 0);
    });

    test('returns zero for an empty cart', () {
      expect(Cart.empty().quantityOf('p-1'), 0);
    });
  });
}
