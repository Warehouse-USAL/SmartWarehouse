import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:cart/src/presentation/widgets/create_order_confirmation_dialog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Abre el diálogo vía su único punto de entrada (show) y captura el result.
  Future<void> open(
    WidgetTester tester,
    Cart cart,
    void Function(bool) onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              onResult(await CreateOrderConfirmationDialog.show(context, cart));
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('wording singular para una sola unidad', (tester) async {
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await open(tester, cart, (_) {});

    expect(find.textContaining('1 unidad.'), findsOneWidget);
    expect(find.text('Confirmar orden'), findsOneWidget);
  });

  testWidgets('wording plural con productos y unidades', (tester) async {
    final cart = Cart(
      items: [
        CartItem(product: aProduct(id: 'a'), quantity: 2),
        CartItem(product: aProduct(id: 'b'), quantity: 1),
      ],
    );

    await open(tester, cart, (_) {});

    expect(find.textContaining('2 productos · 3 unidades'), findsOneWidget);
  });

  testWidgets('muestra el total con su key de e2e', (tester) async {
    final cart = Cart(
      items: [
        CartItem(product: aProduct(price: aMoney(amount: 1000)), quantity: 1),
      ],
    );

    await open(tester, cart, (_) {});

    final totalText = tester.widget<Text>(
      find.byKey(E2eKeys.orderConfirmDialogTotal),
    );
    expect(totalText.data, cart.total!.formatted);
  });

  testWidgets('sin total (carrito vacio) no hay fila de total', (tester) async {
    await open(tester, Cart.empty(), (_) {});

    expect(find.byKey(E2eKeys.orderConfirmDialogTotal), findsNothing);
  });

  testWidgets('es un SwDialog de marca con las keys de accion', (tester) async {
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await open(tester, cart, (_) {});

    expect(find.byType(SwDialog), findsOneWidget);
    expect(find.byKey(E2eKeys.orderConfirmAccept), findsOneWidget);
    expect(find.byKey(E2eKeys.orderConfirmCancel), findsOneWidget);
  });

  testWidgets('tapping Cancelar resolves show() with false', (tester) async {
    bool? result;
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await open(tester, cart, (r) => result = r);
    await tester.tap(find.byKey(E2eKeys.orderConfirmCancel));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('tapping Confirmar resolves show() with true', (tester) async {
    bool? result;
    final cart = Cart(items: [CartItem(product: aProduct(), quantity: 1)]);

    await open(tester, cart, (r) => result = r);
    await tester.tap(find.byKey(E2eKeys.orderConfirmAccept));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
