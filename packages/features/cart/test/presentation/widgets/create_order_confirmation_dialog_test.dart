import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:cart/src/presentation/widgets/create_order_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

void main() {
  testWidgets('shows singular wording for a single unit', (tester) async {
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CreateOrderConfirmationDialog(cart: cart)),
    ));

    expect(find.text('1 unidad'), findsOneWidget);
  });

  testWidgets('shows plural wording for more than one unit', (tester) async {
    final cart = Cart(items: [
      CartItem(product: aProduct(id: 'a'), quantity: 2),
      CartItem(product: aProduct(id: 'b'), quantity: 1),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CreateOrderConfirmationDialog(cart: cart)),
    ));

    expect(find.text('3 unidades'), findsOneWidget);
  });

  testWidgets('shows the total when the cart has one', (tester) async {
    final cart = Cart(items: [
      CartItem(product: aProduct(price: aMoney(amount: 1000)), quantity: 1),
    ]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CreateOrderConfirmationDialog(cart: cart)),
    ));

    expect(find.text('Total: ${cart.total!.formatted}'), findsOneWidget);
  });

  testWidgets('hides the total line for an empty cart', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CreateOrderConfirmationDialog(cart: Cart.empty())),
    ));

    expect(find.textContaining('Total:'), findsNothing);
  });

  testWidgets('tapping Cancelar resolves show() with false', (tester) async {
    bool? result;
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await CreateOrderConfirmationDialog.show(context, cart);
          },
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('tapping Confirmar resolves show() with true', (tester) async {
    bool? result;
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await CreateOrderConfirmationDialog.show(context, cart);
          },
          child: const Text('open'),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
