import 'package:design_system/dialog/custom_dialog.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('CustomDialog', () {
    testWidgets('renderiza el child', (tester) async {
      await pumpDs(tester, const CustomDialog(child: Text('confirmar?')));
      expect(find.text('confirmar?'), findsOneWidget);
    });

    testWidgets('el padding por defecto es 16', (tester) async {
      await pumpDs(tester, const CustomDialog(child: Text('confirmar?')));

      expect(
        find.descendant(
          of: find.byType(CustomDialog),
          matching: find.byWidgetPredicate(
            (w) => w is Padding && w.padding == const EdgeInsets.all(16),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('respeta un padding propio', (tester) async {
      await pumpDs(
        tester,
        const CustomDialog(
          padding: EdgeInsets.all(32),
          child: Text('confirmar?'),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(CustomDialog),
          matching: find.byWidgetPredicate(
            (w) => w is Padding && w.padding == const EdgeInsets.all(32),
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('se pinta con los colores del tema', (tester) async {
      late CustomThemeExtension theme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            theme = CustomThemeExtension.of(context);
            return const CustomDialog(child: Text('confirmar?'));
          },
        ),
      );

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, theme.primaryWhite);
      expect(
        (dialog.shape! as RoundedRectangleBorder).side.color,
        theme.black10,
      );
    });
  });

  group('CustomDialog.show', () {
    /// Monta un boton que abre el dialogo, porque `show` necesita un context
    /// con `Navigator` arriba.
    Future<void> pumpOpener(
      WidgetTester tester, {
      bool barrierDismissible = true,
    }) => pumpDs(
      tester,
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => CustomDialog.show(
            context: context,
            barrierDismissible: barrierDismissible,
            child: const Text('confirmar?'),
          ),
          child: const Text('abrir'),
        ),
      ),
    );

    testWidgets('monta el dialogo sobre la pantalla', (tester) async {
      await pumpOpener(tester);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomDialog), findsOneWidget);
      expect(find.text('confirmar?'), findsOneWidget);
    });

    testWidgets('por defecto se cierra tocando afuera', (tester) async {
      await pumpOpener(tester);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(CustomDialog), findsNothing);
    });

    testWidgets('con barrierDismissible en false no se cierra tocando afuera', (
      tester,
    ) async {
      // Es la diferencia entre un aviso y una confirmacion obligatoria: si el
      // flag no se propaga, un dialogo de "confirmar pedido" se cierra solo.
      await pumpOpener(tester, barrierDismissible: false);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(CustomDialog), findsOneWidget);
    });
  });
}
