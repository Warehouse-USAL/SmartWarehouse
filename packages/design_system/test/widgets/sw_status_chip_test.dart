import 'package:design_system/theme/sw_tokens.dart';
import 'package:design_system/widgets/sw_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('renderiza label con colores dados y punto', (tester) async {
    await pumpDs(
      tester,
      const SwStatusChip(
        label: 'Cancelado',
        color: SwColors.danger,
        background: SwColors.dangerSoft,
      ),
    );

    expect(find.text('Cancelado'), findsOneWidget);
    final text = tester.widget<Text>(find.text('Cancelado'));
    expect(text.style?.color, SwColors.danger);

    final container = tester.widget<Container>(find.byType(Container).first);
    expect((container.decoration! as BoxDecoration).color, SwColors.dangerSoft);

    // El punto: un Container circular del color del texto.
    final dot = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).shape == BoxShape.circle,
        )
        .single;
    expect((dot.decoration! as BoxDecoration).color, SwColors.danger);
  });

  testWidgets('dot: false oculta el punto', (tester) async {
    await pumpDs(
      tester,
      const SwStatusChip(
        label: 'Completado',
        color: SwColors.stockIn,
        background: SwColors.okSoft,
        dot: false,
      ),
    );

    final dots = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).shape == BoxShape.circle,
        );
    expect(dots, isEmpty);
  });

  testWidgets('usa radio pill', (tester) async {
    await pumpDs(
      tester,
      const SwStatusChip(
        label: 'Pendiente',
        color: SwColors.yellowDark,
        background: SwColors.yellowSoft,
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    expect(
      (container.decoration! as BoxDecoration).borderRadius,
      BorderRadius.circular(SwRadii.pill),
    );
  });
}
