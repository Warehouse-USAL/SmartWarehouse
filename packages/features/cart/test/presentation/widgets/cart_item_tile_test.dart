import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:cart/src/presentation/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders the product sku, name and formatted subtotal', (tester) async {
    final item = CartItem(
      product: aProduct(sku: 'SKU-42', name: 'Martillo'),
      quantity: 2,
    );

    await tester.pumpWidget(wrap(CartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onRemove: () {},
    )));

    expect(find.text('SKU-42'), findsOneWidget);
    expect(find.text('Martillo'), findsOneWidget);
    expect(find.text(item.subtotal.formatted), findsOneWidget);
  });

  testWidgets('tapping Quitar calls onRemove', (tester) async {
    var removed = false;
    final item = CartItem(product: aProduct(), quantity: 1);

    await tester.pumpWidget(wrap(CartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onRemove: () => removed = true,
    )));

    await tester.tap(find.text('Quitar'));
    await tester.pump();

    expect(removed, isTrue);
  });

  testWidgets('un item marcado unavailable se atenua y muestra el chip', (tester) async {
    final item = CartItem(product: aProduct(), quantity: 1, unavailable: true);

    await tester.pumpWidget(wrap(CartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onRemove: () {},
    )));

    expect(find.text('Ya no disponible'), findsOneWidget);
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.55);
  });

  testWidgets('cantidad mayor al stock muestra cuantas unidades quedan', (tester) async {
    final item = CartItem(
      product: aProduct(stock: aStock(available: 2)),
      quantity: 5,
    );

    await tester.pumpWidget(wrap(CartItemTile(
      item: item,
      onQuantityChanged: (_) {},
      onRemove: () {},
    )));

    expect(find.text('Sin stock suficiente (quedan 2)'), findsOneWidget);
  });

  testWidgets('the embedded stepper reports quantity changes for this item', (tester) async {
    int? received;
    final item = CartItem(product: aProduct(), quantity: 2);

    await tester.pumpWidget(wrap(CartItemTile(
      item: item,
      onQuantityChanged: (q) => received = q,
      onRemove: () {},
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(received, 3);
  });
}
