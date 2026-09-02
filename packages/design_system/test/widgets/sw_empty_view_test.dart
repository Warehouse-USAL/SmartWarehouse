import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Future<void> pumpEmpty(
    WidgetTester tester, {
    IconData? icon,
    String? ctaLabel,
    VoidCallback? onCtaPressed,
  }) => pumpDs(
    tester,
    SwEmptyView(
      title: 'Sin resultados',
      message: 'Probá con otro filtro',
      icon: icon ?? Icons.inventory_2_outlined,
      ctaLabel: ctaLabel,
      onCtaPressed: onCtaPressed,
    ),
  );

  testWidgets('renderiza titulo y mensaje', (tester) async {
    await pumpEmpty(tester);

    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Probá con otro filtro'), findsOneWidget);
  });

  testWidgets('usa el icono por defecto', (tester) async {
    await pumpEmpty(tester);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  testWidgets('acepta un icono propio', (tester) async {
    await pumpEmpty(tester, icon: Icons.search_off);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  // La guarda del CTA es `ctaLabel != null && onCtaPressed != null`: un `&&`
  // con dos parametros opcionales e independientes. Los tres casos negativos
  // son ramas reales, no defensa de mas — un boton renderizado sin callback
  // seria un boton muerto en pantalla.
  group('CTA', () {
    testWidgets('no aparece sin label ni callback', (tester) async {
      await pumpEmpty(tester);
      expect(find.byType(SwButton), findsNothing);
    });

    testWidgets('no aparece con label pero sin callback', (tester) async {
      await pumpEmpty(tester, ctaLabel: 'Reintentar');

      expect(find.byType(SwButton), findsNothing);
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('no aparece con callback pero sin label', (tester) async {
      await pumpEmpty(tester, onCtaPressed: () {});
      expect(find.byType(SwButton), findsNothing);
    });

    testWidgets('aparece con los dos', (tester) async {
      await pumpEmpty(tester, ctaLabel: 'Reintentar', onCtaPressed: () {});

      expect(find.byType(SwButton), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('dispara el callback al tocarse', (tester) async {
      var taps = 0;
      await pumpEmpty(
        tester,
        ctaLabel: 'Reintentar',
        onCtaPressed: () => taps++,
      );

      await tester.tap(find.byType(SwButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('se dibuja como variante secundaria', (tester) async {
      await pumpEmpty(tester, ctaLabel: 'Reintentar', onCtaPressed: () {});

      expect(
        tester.widget<SwButton>(find.byType(SwButton)).variant,
        SwButtonVariant.secondary,
      );
    });
  });
}
