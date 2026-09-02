import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_component.dart';
import 'package:cart/cart.dart';
import 'package:commons/commons.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';

import '../../support/harness.dart';

void main() {
  setUp(injectCart);
  tearDown(disposeCart);

  /// Monta el componente y devuelve la lista de opciones que reporta al
  /// tocarse cada tab.
  Future<List<NavigationBarOption>> pumpComponent(
    WidgetTester tester, {
    required NavigationBarOption selectedTab,
  }) async {
    final pressed = <NavigationBarOption>[];
    await pumpNav(
      tester,
      BottomNavigationComponent(
        selectedTab: selectedTab,
        onItemPressed: (_, option) => pressed.add(option),
      ),
    );
    return pressed;
  }

  SwBottomNav navOf(WidgetTester tester) =>
      tester.widget<SwBottomNav>(find.byType(SwBottomNav));

  group('activeId', () {
    const cases = <String, NavigationBarOption>{
      'products': NavigationBarOption.products(),
      'cart': NavigationBarOption.cart(),
      'orders': NavigationBarOption.orders(),
      'profile': NavigationBarOption.profile(),
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key} marca su propio tab como activo',
          (tester) async {
        await pumpComponent(tester, selectedTab: entry.value);
        expect(navOf(tester).activeId, entry.key);
      });
    }
  });

  group('onItemPressed', () {
    const expected = <String, NavigationBarOption>{
      'products': NavigationBarOption.products(),
      'cart': NavigationBarOption.cart(),
      'orders': NavigationBarOption.orders(),
      'profile': NavigationBarOption.profile(),
    };

    for (final entry in expected.entries) {
      testWidgets('tocar ${entry.key} reporta su opción', (tester) async {
        final pressed = await pumpComponent(
          tester,
          selectedTab: const NavigationBarOption.products(),
        );

        await tester.tap(find.byKey(E2eKeys.navTab(entry.key)));
        await tester.pump();

        expect(pressed, [entry.value]);
      });
    }
  });

  group('badge del carrito', () {
    SwNavTab cartTabOf(WidgetTester tester) =>
        navOf(tester).tabs.firstWhere((t) => t.id == 'cart');

    testWidgets('es 0 con el carrito vacío', (tester) async {
      await pumpComponent(
        tester,
        selectedTab: const NavigationBarOption.products(),
      );

      expect(cartTabOf(tester).badgeCount, 0);
    });

    testWidgets('suma cantidades, no items', (tester) async {
      // `Cart.itemCount` es `items.fold(0, (sum, i) => sum + i.quantity)`.
      // Un solo producto con cantidad 3 vale 3, no 1: este test es lo que
      // separa `itemCount` de `items.length` si alguien los intercambia.
      Injector.i.resolve<CartCubit>().add(aProduct(), quantity: 3);
      await pumpComponent(
        tester,
        selectedTab: const NavigationBarOption.products(),
      );

      expect(cartTabOf(tester).badgeCount, 3);
    });

    testWidgets('acumula entre productos distintos', (tester) async {
      Injector.i.resolve<CartCubit>()
        ..add(aProduct(id: 'p-1'), quantity: 2)
        ..add(aProduct(id: 'p-2'), quantity: 5);
      await pumpComponent(
        tester,
        selectedTab: const NavigationBarOption.products(),
      );

      expect(cartTabOf(tester).badgeCount, 7);
    });

    testWidgets('se actualiza cuando cambia el carrito', (tester) async {
      await pumpComponent(
        tester,
        selectedTab: const NavigationBarOption.products(),
      );
      expect(cartTabOf(tester).badgeCount, 0);

      Injector.i.resolve<CartCubit>().add(aProduct(), quantity: 4);
      await pumpBloc(tester);

      expect(cartTabOf(tester).badgeCount, 4);
    });
  });

  testWidgets('los cuatro tabs se renderizan en orden', (tester) async {
    await pumpComponent(
      tester,
      selectedTab: const NavigationBarOption.products(),
    );

    expect(
      navOf(tester).tabs.map((t) => t.id),
      ['products', 'cart', 'orders', 'profile'],
    );
  });
}
