import 'package:design_system/widgets/sw_loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  BoxDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(SwLoadingSkeleton),
                  matching: find.byType(Container),
                ),
              )
              .decoration!
          as BoxDecoration;

  testWidgets('respeta el ancho y el alto que recibe', (tester) async {
    await pumpDs(
      tester,
      const SwLoadingSkeleton(width: 120, height: 16),
    );

    final size = tester.getSize(find.byType(SwLoadingSkeleton));
    expect(size.width, 120);
    expect(size.height, 16);
  });

  testWidgets('el radio por defecto es 8', (tester) async {
    await pumpDs(tester, const SwLoadingSkeleton(width: 100, height: 10));

    expect(
      decorationOf(tester).borderRadius,
      BorderRadius.circular(8),
    );
  });

  group('.circle', () {
    testWidgets('usa el size como ancho y alto', (tester) async {
      await pumpDs(tester, SwLoadingSkeleton.circle(size: 40));

      expect(tester.getSize(find.byType(SwLoadingSkeleton)), const Size(40, 40));
    });

    testWidgets('el radio es la mitad del size', (tester) async {
      // Es lo unico que hace el factory: `borderRadius = size / 2`. Con
      // cualquier otro valor el skeleton circular sale con esquinas.
      await pumpDs(tester, SwLoadingSkeleton.circle(size: 40));

      expect(decorationOf(tester).borderRadius, BorderRadius.circular(20));
    });
  });

  group('animacion', () {
    testWidgets('el color cambia entre frames', (tester) async {
      // El `AnimationController` corre en `repeat(reverse: true)` sobre 1200ms
      // y el color sale de un `Color.lerp` con `_controller.value`. Si el
      // controller no arranca, el skeleton queda estatico y no se nota mirando
      // el arbol: hay que comparar dos frames.
      await pumpDs(tester, const SwLoadingSkeleton(width: 100, height: 10));
      final first = decorationOf(tester).color;

      await tester.pump(const Duration(milliseconds: 600));

      expect(decorationOf(tester).color, isNot(first));
    });

    testWidgets('desmontarlo no deja el controller colgado', (tester) async {
      // Un `AnimationController` sin `dispose` hace fallar el test siguiente
      // con "A Ticker was leaked". El caso existe para que ese leak explote
      // acá y no en el archivo que corra despues.
      await pumpDs(tester, const SwLoadingSkeleton(width: 100, height: 10));
      await pumpDs(tester, const SizedBox.shrink());

      expect(find.byType(SwLoadingSkeleton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
