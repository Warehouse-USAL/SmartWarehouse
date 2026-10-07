import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  InkWell inkOf(WidgetTester tester) => tester.widget<InkWell>(
    find.descendant(
      of: find.byType(PressableWidget),
      matching: find.byType(InkWell),
    ),
  );

  Material materialOf(WidgetTester tester) => tester.widget<Material>(
    find.descendant(
      of: find.byType(PressableWidget),
      matching: find.byType(Material),
    ),
  );

  testWidgets('dispara onPressed al tocarse', (tester) async {
    var taps = 0;
    await pumpDs(
      tester,
      PressableWidget(
        onPressed: () => taps++,
        child: const Text('tocame'),
      ),
    );

    await tester.tap(find.text('tocame'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('onPressed null deja el InkWell sin onTap', (tester) async {
    // `_onPressedCallback` devuelve null cuando no hay `onPressed`, en vez de
    // devolver un callback vacio. La diferencia no es cosmetica: un `InkWell`
    // con `onTap` no-null igual muestra el ripple, y un boton deshabilitado
    // que "responde" al toque se lee como que la app se colgo.
    await pumpDs(
      tester,
      const PressableWidget(child: Text('tocame')),
    );

    expect(inkOf(tester).onTap, isNull);
  });

  testWidgets('deshabilitado pinta con disabledColor', (tester) async {
    await pumpDs(
      tester,
      const PressableWidget(
        disabledColor: Colors.grey,
        backgroundColor: Colors.blue,
        child: Text('tocame'),
      ),
    );

    expect(materialOf(tester).color, Colors.grey);
  });

  testWidgets('habilitado pinta con backgroundColor', (tester) async {
    await pumpDs(
      tester,
      PressableWidget(
        onPressed: () {},
        disabledColor: Colors.grey,
        backgroundColor: Colors.blue,
        child: const Text('tocame'),
      ),
    );

    expect(materialOf(tester).color, Colors.blue);
  });

  testWidgets('propaga borderRadius al Material y al InkWell', (tester) async {
    // Van a los dos: el `Material` recorta el fondo y el `InkWell` recorta el
    // ripple. Cablear uno solo deja el splash cuadrado sobre un fondo
    // redondeado.
    final radius = BorderRadius.circular(16);
    await pumpDs(
      tester,
      PressableWidget(
        onPressed: () {},
        borderRadius: radius,
        child: const Text('tocame'),
      ),
    );

    expect(materialOf(tester).borderRadius, radius);
    expect(inkOf(tester).borderRadius, radius);
  });

  testWidgets('pressedColor pinta splash y highlight', (tester) async {
    await pumpDs(
      tester,
      PressableWidget(
        onPressed: () {},
        pressedColor: Colors.amber,
        child: const Text('tocame'),
      ),
    );

    expect(inkOf(tester).splashColor, Colors.amber);
    expect(inkOf(tester).highlightColor, Colors.amber);
  });

  testWidgets('renderiza el child', (tester) async {
    await pumpDs(
      tester,
      const PressableWidget(child: Text('contenido')),
    );

    expect(find.text('contenido'), findsOneWidget);
  });
}
