import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_timeline.dart';
import 'package:orders/orders.dart';

Future<void> _pump(WidgetTester tester, OrderStatus status) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderStatusTimeline(status: status),
        ),
      ),
    );

void main() {
  testWidgets('pending muestra los tres pasos del stepper', (tester) async {
    await _pump(tester, OrderStatus.pending);

    // Cada label aparece dos veces: en el bubble horizontal y en la lista
    // vertical. Afirmamos eso y no una sola ocurrencia, porque el widget
    // dibuja las dos representaciones a proposito.
    expect(find.text('Pendiente'), findsNWidgets(2));
    expect(find.text('En progreso'), findsNWidgets(2));
    expect(find.text('Completado'), findsNWidgets(2));
  });

  testWidgets('inProgress renderiza sin romperse y mantiene los tres pasos',
      (tester) async {
    await _pump(tester, OrderStatus.inProgress);

    expect(find.text('En progreso'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed renderiza los tres pasos', (tester) async {
    await _pump(tester, OrderStatus.completed);

    expect(find.text('Completado'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled reemplaza el stepper por el banner', (tester) async {
    await _pump(tester, OrderStatus.cancelled);

    // El camino de cancelada es un subtree distinto: no hay stepper.
    expect(find.text('Pendiente'), findsNothing);
    expect(find.text('En progreso'), findsNothing);
    expect(find.text('Completado'), findsNothing);
    // Assertion positiva: el banner tiene un texto propio y estable.
    expect(find.text('Orden cancelada'), findsOneWidget);
  });

  testWidgets('cancelled no deja el arbol en estado de error', (tester) async {
    await _pump(tester, OrderStatus.cancelled);

    expect(tester.takeException(), isNull);
  });

  // El estado "done" de una burbuja dibuja un check en lugar del numero: los
  // numeros 1/2/3 solo aparecen para los pasos que todavia no se completaron.
  // Por eso se prueba cada estado por separado en vez de esperar "1 a 3" en
  // los tres estados por igual (eso no es lo que el widget hace).
  testWidgets('pending numera las tres burbujas porque ningun paso esta completo',
      (tester) async {
    await _pump(tester, OrderStatus.pending);

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'inProgress marca el primer paso con un check y numera los restantes',
      (tester) async {
    await _pump(tester, OrderStatus.inProgress);

    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed marca los tres pasos con un check y no numera ninguno',
      (tester) async {
    await _pump(tester, OrderStatus.completed);

    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsNothing);
    expect(find.byIcon(Icons.check), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cambiar el status re-renderiza sin errores', (tester) async {
    await _pump(tester, OrderStatus.pending);
    await _pump(tester, OrderStatus.completed);
    await _pump(tester, OrderStatus.cancelled);

    expect(tester.takeException(), isNull);
  });
}
