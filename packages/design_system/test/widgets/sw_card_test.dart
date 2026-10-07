import 'package:design_system/theme/sw_tokens.dart';
import 'package:design_system/widgets/sw_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('renderiza el child', (tester) async {
    await pumpDs(tester, const SwCard(child: Text('contenido')));
    expect(find.text('contenido'), findsOneWidget);
  });

  /// Se busca por el valor del `padding` y no por `find.byType(Padding)`: el
  /// `Container` con borde ya monta un `Padding` propio para las dimensiones
  /// del `Border`, asi que contar Paddings mide a Flutter, no a `SwCard`.
  Finder paddingWith(EdgeInsetsGeometry value) => find.descendant(
    of: find.byType(SwCard),
    matching: find.byWidgetPredicate(
      (w) => w is Padding && w.padding == value,
    ),
  );

  testWidgets('sin padding no envuelve el child', (tester) async {
    // El widget hace `padding == null ? child : Padding(...)`.
    await pumpDs(tester, const SwCard(child: Text('contenido')));

    expect(paddingWith(const EdgeInsets.all(16)), findsNothing);
  });

  testWidgets('con padding envuelve el child', (tester) async {
    await pumpDs(
      tester,
      const SwCard(
        padding: EdgeInsets.all(16),
        child: Text('contenido'),
      ),
    );

    expect(paddingWith(const EdgeInsets.all(16)), findsOneWidget);
  });

  testWidgets('usa el radio y la sombra de card del design system', (
    tester,
  ) async {
    await pumpDs(tester, const SwCard(child: Text('contenido')));

    final decoration =
        tester
                .widget<Container>(
                  find.descendant(
                    of: find.byType(SwCard),
                    matching: find.byType(Container),
                  ),
                )
                .decoration!
            as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(SwRadii.card));
    expect(decoration.boxShadow, SwShadows.card);
    expect(decoration.color, SwColors.white);
  });
}
