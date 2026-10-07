import 'package:cart/cart.dart';
import 'package:cart/src/data/mappers/cart_order_mapper.dart';
import 'package:catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id, {int cents = 1000, String currency = 'ARS'}) {
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
  group('CartOrderMapper.toOrderItems', () {
    test('carrito vacío mapea a lista vacía', () {
      expect(Cart.empty().toOrderItems(), isEmpty);
    });

    test('mapea id, nombre, precio unitario y cantidad de cada línea', () {
      final cases = [
        (product: _product('a', cents: 1500), quantity: 1),
        (product: _product('b', cents: 200, currency: 'USD'), quantity: 3),
        (product: _product('c', cents: 99999), quantity: 7),
      ];
      final cart = Cart(
        items: [
          for (final c in cases) CartItem(product: c.product, quantity: c.quantity),
        ],
      );

      final items = cart.toOrderItems();

      expect(items, hasLength(cases.length));
      for (var i = 0; i < cases.length; i++) {
        expect(items[i].productId, cases[i].product.id);
        expect(items[i].productName, cases[i].product.name);
        expect(items[i].unitPrice, cases[i].product.price);
        expect(items[i].quantity, cases[i].quantity);
      }
    });

    test('preserva el orden de las líneas del carrito', () {
      final cart = Cart(items: [
        CartItem(product: _product('z'), quantity: 1),
        CartItem(product: _product('a'), quantity: 1),
      ]);
      expect(cart.toOrderItems().map((i) => i.productId), ['z', 'a']);
    });
  });
}
