import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_scaffold.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  setUp(injectCart);
  tearDown(disposeCart);

  const child = Text('contenido', key: Key('child'));

  Future<void> pumpScaffold(
    WidgetTester tester, {
    bool scrollable = true,
    bool showBottomNavigationBar = true,
    AlignmentGeometry? alignment,
    PreferredSizeWidget? appBar,
  }) async {
    // El scaffold trae su propio `Scaffold`, así que se monta directo bajo
    // `MaterialApp` en vez de con `pumpNav`, que envuelve en otro.
    await pumpBare(
      tester,
      BottomNavigationScaffold(
        selectedTab: const NavigationBarOption.products(),
        scrollable: scrollable,
        showBottomNavigationBar: showBottomNavigationBar,
        alignment: alignment,
        appBar: appBar,
        child: child,
      ),
    );
  }

  Align alignOf(WidgetTester tester) => tester.widget<Align>(
        find.ancestor(of: find.byKey(const Key('child')), matching: find.byType(Align)).first,
      );

  testWidgets('renderiza el child', (tester) async {
    await pumpScaffold(tester);
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  group('showBottomNavigationBar', () {
    testWidgets('true monta la barra', (tester) async {
      await pumpScaffold(tester);
      expect(find.byType(SwBottomNav), findsOneWidget);
    });

    testWidgets('false no la monta', (tester) async {
      await pumpScaffold(tester, showBottomNavigationBar: false);
      expect(find.byType(SwBottomNav), findsNothing);
    });
  });

  group('scrollable', () {
    testWidgets('true envuelve en SingleChildScrollView', (tester) async {
      await pumpScaffold(tester);
      expect(
        find.ancestor(
          of: find.byKey(const Key('child')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('false no lo envuelve', (tester) async {
      await pumpScaffold(tester, scrollable: false);
      expect(
        find.ancestor(
          of: find.byKey(const Key('child')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });
  });

  group('alignment', () {
    testWidgets('sin alignment usa topStart', (tester) async {
      await pumpScaffold(tester);
      expect(alignOf(tester).alignment, AlignmentDirectional.topStart);
    });

    testWidgets('respeta el alignment que se le pasa', (tester) async {
      await pumpScaffold(tester, alignment: Alignment.center);
      expect(alignOf(tester).alignment, Alignment.center);
    });

    testWidgets('el default aplica también sin scroll', (tester) async {
      // `scrollable` elige entre dos ramas que construyen su propio `Align`.
      // Sin este caso, la rama no scrolleable podría perder el default y
      // ningún test se enteraría.
      await pumpScaffold(tester, scrollable: false);
      expect(alignOf(tester).alignment, AlignmentDirectional.topStart);
    });
  });

  group('appBar', () {
    testWidgets('sin appBar no renderiza ninguno', (tester) async {
      await pumpScaffold(tester);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('pasa el appBar que recibe', (tester) async {
      await pumpScaffold(
        tester,
        appBar: AppBar(title: const Text('titulo')),
      );
      expect(find.widgetWithText(AppBar, 'titulo'), findsOneWidget);
    });
  });
}
