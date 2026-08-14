import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:cart/src/presentation/widgets/cart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

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
