import 'package:design_system/theme/sw_tokens.dart';
import 'package:design_system/widgets/sw_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Future<void> pumpTrigger(
    WidgetTester tester,
    void Function(BuildContext) onTap,
  ) async {
    await pumpBare(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => onTap(context),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('show renderiza mensaje con fondo oscuro flotante', (
    tester,
  ) async {
    await pumpTrigger(
      tester,
      (c) => SwSnackBar.show(c, message: 'Orden creada'),
    );

    expect(find.text('Orden creada'), findsOneWidget);
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.backgroundColor, SwColors.text);
    expect(snack.behavior, SnackBarBehavior.floating);
  });

  testWidgets('detail se muestra como segunda linea', (tester) async {
    await pumpTrigger(
      tester,
      (c) => SwSnackBar.show(
        c,
        message: '2 productos agregados',
        detail: '1 sin stock quedó afuera',
      ),
    );

    expect(find.text('2 productos agregados'), findsOneWidget);
    expect(find.text('1 sin stock quedó afuera'), findsOneWidget);
  });

  testWidgets('sin detail no hay segunda linea', (tester) async {
    await pumpTrigger(tester, (c) => SwSnackBar.show(c, message: 'Hola'));

    // Un solo Text dentro del content (ademas del action inexistente).
    final snack = find.byType(SnackBar);
    expect(
      find.descendant(of: snack, matching: find.byType(Text)),
      findsOneWidget,
    );
  });

  testWidgets('la accion dispara el callback', (tester) async {
    var pressed = 0;
    await pumpTrigger(
      tester,
      (c) => SwSnackBar.show(
        c,
        message: 'Agregado',
        actionLabel: 'VER PEDIDO',
        onAction: () => pressed++,
      ),
    );

    await tester.tap(find.text('VER PEDIDO'));
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('showError usa el icono de alerta en tile rojo', (tester) async {
    await pumpTrigger(
      tester,
      (c) => SwSnackBar.showError(c, message: 'No se pudo guardar'),
    );

    expect(find.text('No se pudo guardar'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snack.backgroundColor, SwColors.text);
  });

  testWidgets('showError con detail y accion', (tester) async {
    var pressed = 0;
    await pumpTrigger(
      tester,
      (c) => SwSnackBar.showError(
        c,
        message: 'Fallo la orden',
        detail: 'Reintenta en unos segundos',
        actionLabel: 'REINTENTAR',
        onAction: () => pressed++,
      ),
    );

    expect(find.text('Reintenta en unos segundos'), findsOneWidget);
    await tester.tap(find.text('REINTENTAR'));
    expect(pressed, 1);
  });
}
