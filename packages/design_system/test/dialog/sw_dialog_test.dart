import 'package:design_system/buttons/sw_button.dart';
import 'package:design_system/dialog/sw_dialog.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  /// Monta una pantalla con un botón que abre el diálogo y captura el
  /// resultado del Future — el contrato público de SwDialog.show.
  Future<void> pumpOpener(
    WidgetTester tester, {
    required List<bool> results,
    String? message,
    Widget? body,
    bool destructive = false,
  }) async {
    await pumpBare(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                results.add(
                  await SwDialog.show(
                    context,
                    title: 'Confirmar orden',
                    message: message,
                    body: body,
                    confirmLabel: 'Confirmar',
                    cancelLabel: 'Volver',
                    destructive: destructive,
                    confirmKey: const Key('dlg-confirm'),
                    cancelKey: const Key('dlg-cancel'),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra titulo, mensaje y acciones', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results, message: '3 productos');

    expect(find.text('Confirmar orden'), findsOneWidget);
    expect(find.text('3 productos'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });

  testWidgets('confirmar resuelve true', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results);

    await tester.tap(find.byKey(const Key('dlg-confirm')));
    await tester.pumpAndSettle();

    expect(results, [true]);
    expect(find.text('Confirmar orden'), findsNothing);
  });

  testWidgets('cancelar resuelve false', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results);

    await tester.tap(find.byKey(const Key('dlg-cancel')));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('tocar afuera (barrier) resuelve false, no null', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results);

    // El barrier ocupa toda la pantalla salvo el diálogo: tap en una esquina.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('sin destructive el confirmar es amarillo y no hay icono', (
    tester,
  ) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results);

    final confirm = tester.widget<SwButton>(
      find.byKey(const Key('dlg-confirm')),
    );
    expect(confirm.variant, SwButtonVariant.primary);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('destructive muestra icono rojo y boton danger', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results, destructive: true);

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    final confirm = tester.widget<SwButton>(
      find.byKey(const Key('dlg-confirm')),
    );
    expect(confirm.variant, SwButtonVariant.danger);
  });

  testWidgets('renderiza el body custom entre mensaje y acciones', (
    tester,
  ) async {
    final results = <bool>[];
    await pumpOpener(
      tester,
      results: results,
      body: const Text('TOTAL-SLOT', key: Key('dlg-body')),
    );

    expect(find.byKey(const Key('dlg-body')), findsOneWidget);
  });

  testWidgets('usa el radio de card y fondo blanco de marca', (tester) async {
    final results = <bool>[];
    await pumpOpener(tester, results: results);

    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.backgroundColor, SwColors.white);
    final shape = dialog.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(SwRadii.card));
  });
}
