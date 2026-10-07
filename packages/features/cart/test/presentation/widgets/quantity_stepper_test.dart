import 'package:cart/src/presentation/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('renders the current quantity', (tester) async {
    await tester.pumpWidget(wrap(QuantityStepper(quantity: 3, onChanged: (_) {})));

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tapping the increment button calls onChanged with quantity + 1', (tester) async {
    int? received;
    await tester.pumpWidget(wrap(QuantityStepper(
      quantity: 2,
      onChanged: (q) => received = q,
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(received, 3);
  });

  testWidgets('tapping the decrement button calls onChanged with quantity - 1', (tester) async {
    int? received;
    await tester.pumpWidget(wrap(QuantityStepper(
      quantity: 2,
      onChanged: (q) => received = q,
    )));

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(received, 1);
  });

  testWidgets('decrement is disabled at the minimum, tapping it does nothing', (tester) async {
    int? received;
    await tester.pumpWidget(wrap(QuantityStepper(
      quantity: 1,
      min: 1,
      onChanged: (q) => received = q,
    )));

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(received, isNull);
  });

  testWidgets('increment is disabled at the maximum, tapping it does nothing', (tester) async {
    int? received;
    await tester.pumpWidget(wrap(QuantityStepper(
      quantity: 5,
      max: 5,
      onChanged: (q) => received = q,
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(received, isNull);
  });

  testWidgets('increment stays enabled above the default bound when max is null', (tester) async {
    int? received;
    await tester.pumpWidget(wrap(QuantityStepper(
      quantity: 999,
      onChanged: (q) => received = q,
    )));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(received, 1000);
  });
}
