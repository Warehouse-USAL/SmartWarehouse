import 'package:design_system/widgets/spaces/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('CustomSpace', () {
    test('la escala va de 4 en 4 hasta x5, y despues salta', () {
      // Los valores son la escala de espaciado del design system. Testearlos
      // uno por uno seria testear constantes; lo que se fija acá es que la
      // escala sea monotona: un token fuera de orden pasa desapercibido
      // leyendo el enum y descoloca cualquier pantalla que lo use.
      final values = CustomSpace.values.map((s) => s.value).toList();

      expect(values, orderedEquals(<double>[4, 8, 12, 16, 20, 24, 32]));
      for (var i = 1; i < values.length; i++) {
        expect(values[i], greaterThan(values[i - 1]));
      }
    });
  });

  group('CustomSpacer', () {
    testWidgets('sin argumentos no ocupa lugar', (tester) async {
      // `height?.value ?? 0`: el spacer sin token es el placeholder que usa
      // `CustomAppBar` para equilibrar la fila. Si colapsara a null en vez de
      // 0, el `SizedBox` se estiraria.
      await pumpDs(tester, const CustomSpacer());
      expect(tester.getSize(find.byType(CustomSpacer)), Size.zero);
    });

    testWidgets('height toma el valor del token', (tester) async {
      await pumpDs(tester, const CustomSpacer(height: CustomSpace.x6));
      expect(tester.getSize(find.byType(CustomSpacer)).height, 24);
    });

    testWidgets('width toma el valor del token', (tester) async {
      await pumpDs(tester, const CustomSpacer(width: CustomSpace.x3));
      expect(tester.getSize(find.byType(CustomSpacer)).width, 12);
    });

    testWidgets('height y width son independientes', (tester) async {
      await pumpDs(
        tester,
        const CustomSpacer(height: CustomSpace.x7, width: CustomSpace.x1),
      );

      expect(tester.getSize(find.byType(CustomSpacer)), const Size(4, 32));
    });
  });
}
