import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/presentation/widgets/order_card.dart';
import 'package:orders/orders.dart';
import 'package:orders_test_builders/orders_test_builders.dart';

Future<void> _pump(
  WidgetTester tester,
  Order order, {
  VoidCallback? onTap,
}) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderCard(order: order, onTap: onTap ?? () {}),
        ),
      ),
    );

void main() {
  testWidgets('muestra el id de la orden', (tester) async {
    await _pump(tester, anOrder(id: 'WH-49281'));

    expect(find.text('WH-49281'), findsOneWidget);
  });

  testWidgets('dispara onTap al tocar la card', (tester) async {
    // El `Row` de la card queda forzado al tamano completo del body del
    // Scaffold (constraints tight), asi que su caja incluye espacio vacio a
    // la derecha del contenido real. Tocar por tipo (`find.byType(OrderCard)`)
    // apunta al centro de esa caja entera y puede caer en ese hueco vacio, sin
    // tocar ningun descendiente -> el GestureDetector nunca ve el tap. Tocar
    // un texto realmente renderizado si cae dentro del contenido.
    var tapped = 0;
    await _pump(tester, anOrder(id: 'WH-1'), onTap: () => tapped++);

    await tester.tap(find.text('WH-1'));
    await tester.pump();

    expect(tapped, 1);
  });

  group('formato de fecha', () {
    testWidgets('una orden de hoy dice "Hoy"', (tester) async {
      await _pump(tester, anOrder(createdAt: DateTime.now()));

      expect(find.textContaining('Hoy'), findsOneWidget);
    });

    testWidgets('una orden de ayer dice "Ayer"', (tester) async {
      await _pump(
        tester,
        anOrder(createdAt: DateTime.now().subtract(const Duration(days: 1))),
      );

      expect(find.textContaining('Ayer'), findsOneWidget);
    });

    testWidgets('una orden vieja muestra la fecha en d/m/aaaa', (tester) async {
      await _pump(tester, anOrder(createdAt: DateTime(2026, 3, 7)));

      expect(find.textContaining('7/3/2026'), findsOneWidget);
    });
  });

  group('etiqueta de estado', () {
    for (final (status, label) in const [
      (OrderStatus.pending, 'Pendiente'),
      (OrderStatus.inProgress, 'En progreso'),
      (OrderStatus.completed, 'Completado'),
      (OrderStatus.cancelled, 'Cancelado'),
    ]) {
      testWidgets('$status se muestra como "$label"', (tester) async {
        await _pump(tester, anOrder(status: status));

        expect(find.textContaining(label), findsOneWidget);
      });
    }
  });

  group('total', () {
    testWidgets('muestra el total formateado cuando es mayor a cero',
        (tester) async {
      await _pump(
        tester,
        anOrder(items: [], total: aMoney(amount: 4999900)),
      );

      expect(find.text(r'$49.999'), findsOneWidget);
    });

    testWidgets('muestra un guion cuando el total es cero, no un \$0 falso',
        (tester) async {
      await _pump(tester, anOrder(items: [], total: aMoney(amount: 0)));

      expect(find.text('—'), findsOneWidget);
      expect(find.text(r'$0'), findsNothing);
    });
  });

  testWidgets('muestra la cantidad de items', (tester) async {
    await _pump(
      tester,
      anOrder(items: [anOrderItem(), anOrderItem(productId: 'p-2')]),
    );

    expect(find.textContaining('2 items'), findsOneWidget);
  });
}
