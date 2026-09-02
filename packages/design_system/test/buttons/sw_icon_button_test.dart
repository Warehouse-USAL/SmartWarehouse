import 'package:design_system/buttons/sw_icon_button.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  group('SwIconButton', () {
    testWidgets('dispara el callback al tocarse', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        SwIconButton(icon: Icons.search, onPressed: () => taps++),
      );

      await tester.tap(find.byType(SwIconButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('onPressed null deja el InkWell sin onTap', (tester) async {
      await pumpDs(
        tester,
        const SwIconButton(icon: Icons.search, onPressed: null),
      );

      final ink = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(SwIconButton),
          matching: find.byType(InkWell),
        ),
      );
      expect(ink.onTap, isNull);
    });

    testWidgets('renderiza el icono que recibe', (tester) async {
      await pumpDs(
        tester,
        SwIconButton(icon: Icons.shopping_cart, onPressed: () {}),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('sin badge no monta nada en la esquina', (tester) async {
      await pumpDs(tester, SwIconButton(icon: Icons.search, onPressed: () {}));
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('con badge lo monta arriba a la derecha', (tester) async {
      await pumpDs(
        tester,
        SwIconButton(
          icon: Icons.shopping_cart,
          onPressed: () {},
          badge: const SwBadge(count: 3),
        ),
      );

      expect(find.byType(SwBadge), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('el tooltip vacio es el default, no null', (tester) async {
      // `Tooltip` no acepta `message` null; el widget pasa `tooltip ?? ''`.
      // Si alguien saca el `?? ''` el widget explota en runtime, no compila mal.
      await pumpDs(tester, SwIconButton(icon: Icons.search, onPressed: () {}));

      expect(
        tester.widget<Tooltip>(find.byType(Tooltip)).message,
        isEmpty,
      );
    });

    testWidgets('propaga el tooltip que recibe', (tester) async {
      await pumpDs(
        tester,
        SwIconButton(
          icon: Icons.search,
          onPressed: () {},
          tooltip: 'Buscar',
        ),
      );

      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, 'Buscar');
    });
  });

  group('SwBadge', () {
    Future<void> pumpBadge(WidgetTester tester, int count) =>
        pumpDs(tester, SwBadge(count: count));

    testWidgets('no renderiza nada en 0', (tester) async {
      // La guarda es `count <= 0`. Un badge que dibuja "0" sobre el carrito
      // vacio es el bug que este caso evita.
      await pumpBadge(tester, 0);

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('tampoco renderiza con un count negativo', (tester) async {
      await pumpBadge(tester, -5);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('muestra el numero tal cual entre 1 y 99', (tester) async {
      await pumpBadge(tester, 1);
      expect(find.text('1'), findsOneWidget);

      await pumpBadge(tester, 99);
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('clampea a 99+ arriba de 99', (tester) async {
      // El limite es `> 99`, no `>= 99`: 99 se muestra entero y 100 ya no.
      await pumpBadge(tester, 100);
      expect(find.text('99+'), findsOneWidget);

      await pumpBadge(tester, 12345);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('se pinta con el amarillo de marca', (tester) async {
      await pumpBadge(tester, 3);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SwBadge),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration! as BoxDecoration).color,
        SwColors.yellow,
      );
    });
  });
}
