import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  CircularProgressIndicator indicatorOf(WidgetTester tester) =>
      tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

  testWidgets('por defecto mide 40 y usa el amarillo de marca', (tester) async {
    await pumpDs(tester, const SwLoadingSpinner());

    expect(
      tester.getSize(find.byType(CircularProgressIndicator)),
      const Size(40, 40),
    );
    expect(
      indicatorOf(tester).valueColor!.value,
      SwColors.yellow,
    );
  });

  testWidgets('respeta size, strokeWidth y color', (tester) async {
    await pumpDs(
      tester,
      const SwLoadingSpinner(size: 18, strokeWidth: 2, color: SwColors.text),
    );

    expect(
      tester.getSize(find.byType(CircularProgressIndicator)),
      const Size(18, 18),
    );
    expect(indicatorOf(tester).strokeWidth, 2);
    expect(indicatorOf(tester).valueColor!.value, SwColors.text);
  });

  testWidgets('es indeterminado: no expone progreso', (tester) async {
    // `value` null es lo que hace girar el indicador. Cablearlo a 0 lo deja
    // quieto y el usuario lee "trabado" en vez de "cargando".
    await pumpDs(tester, const SwLoadingSpinner());
    expect(indicatorOf(tester).value, isNull);
  });
}
