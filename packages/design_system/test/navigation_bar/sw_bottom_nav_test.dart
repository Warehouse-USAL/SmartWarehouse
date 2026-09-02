import 'package:design_system/navigation_bar/sw_bottom_nav.dart';
import 'package:design_system/testing/e2e_keys.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  const tabs = <SwNavTab>[
    SwNavTab(id: 'products', label: 'Catalogo', icon: Icons.inventory_2),
    SwNavTab(id: 'cart', label: 'Carrito', icon: Icons.shopping_cart),
    SwNavTab(id: 'orders', label: 'Pedidos', icon: Icons.receipt_long),
    SwNavTab(id: 'profile', label: 'Perfil', icon: Icons.person),
  ];

  Future<List<String>> pumpNav(
    WidgetTester tester, {
    String activeId = 'products',
    List<SwNavTab> items = tabs,
  }) async {
    final selected = <String>[];
    await pumpDs(
      tester,
      SwBottomNav(
        tabs: items,
        activeId: activeId,
        onTabSelected: selected.add,
      ),
    );
    return selected;
  }

  Color colorOfLabel(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;

  group('onTabSelected', () {
    for (final tab in tabs) {
      testWidgets('tocar ${tab.id} reporta su propio id', (tester) async {
        // Los cuatro items se construyen en un `map` sobre la lista, con el
        // callback capturando `t.id`. El bug clasico de esa forma es capturar
        // la variable del loop y reportar siempre el ultimo id.
        final selected = await pumpNav(tester);

        await tester.tap(find.byKey(E2eKeys.navTab(tab.id)));
        await tester.pump();

        expect(selected, [tab.id]);
      });
    }

    testWidgets('tocar el tab activo tambien reporta', (tester) async {
      // Reseleccionar el tab actual es como las apps vuelven al root de ese
      // stack. Filtrarlo acá le sacaría esa opcion al feature.
      final selected = await pumpNav(tester, activeId: 'cart');

      await tester.tap(find.byKey(E2eKeys.navTab('cart')));
      await tester.pump();

      expect(selected, ['cart']);
    });
  });

  group('estado activo', () {
    testWidgets('el activo se pinta con el color fuerte', (tester) async {
      await pumpNav(tester, activeId: 'orders');
      expect(colorOfLabel(tester, 'Pedidos'), SwColors.text);
    });

    testWidgets('los inactivos se pintan atenuados', (tester) async {
      await pumpNav(tester, activeId: 'orders');

      for (final label in ['Catalogo', 'Carrito', 'Perfil']) {
        expect(colorOfLabel(tester, label), SwColors.text3, reason: label);
      }
    });

    testWidgets('un activeId que no existe no marca ninguno', (tester) async {
      await pumpNav(tester, activeId: 'inexistente');

      for (final tab in tabs) {
        expect(colorOfLabel(tester, tab.label), SwColors.text3);
      }
    });
  });

  group('badge', () {
    testWidgets('en 0 no se dibuja', (tester) async {
      await pumpNav(tester);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('muestra el numero entre 1 y 99', (tester) async {
      await pumpNav(
        tester,
        items: const [
          SwNavTab(
            id: 'cart',
            label: 'Carrito',
            icon: Icons.shopping_cart,
            badgeCount: 7,
          ),
        ],
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('99 se muestra entero', (tester) async {
      await pumpNav(
        tester,
        items: const [
          SwNavTab(
            id: 'cart',
            label: 'Carrito',
            icon: Icons.shopping_cart,
            badgeCount: 99,
          ),
        ],
      );

      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('arriba de 99 clampea a 99+', (tester) async {
      await pumpNav(
        tester,
        items: const [
          SwNavTab(
            id: 'cart',
            label: 'Carrito',
            icon: Icons.shopping_cart,
            badgeCount: 100,
          ),
        ],
      );

      expect(find.text('99+'), findsOneWidget);
    });
  });

  testWidgets('cada tab lleva su key de e2e', (tester) async {
    // Los finders de la suite Patrol dependen de estas keys. Cambiar el
    // formato del id rompe la suite e2e sin romper ningun widget test salvo
    // este.
    await pumpNav(tester);

    for (final tab in tabs) {
      expect(find.byKey(E2eKeys.navTab(tab.id)), findsOneWidget);
    }
  });

  testWidgets('renderiza un item por tab, en orden', (tester) async {
    await pumpNav(tester);

    expect(
      tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(SwBottomNav),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data),
      tabs.map((t) => t.label),
    );
  });
}
