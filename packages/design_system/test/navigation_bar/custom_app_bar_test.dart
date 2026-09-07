import 'package:commons/commons.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/navigation_bar/custom_app_bar.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/harness.dart';

class _MockNavigationHelper extends Mock implements NavigationHelper {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late _MockNavigationHelper navigation;

  setUpAll(() => registerFallbackValue(_FakeBuildContext()));

  setUp(() {
    navigation = _MockNavigationHelper();
    registerMock<NavigationHelper>(navigation);
    // El default: la mayoria de los casos no dependen de si se puede volver,
    // y sin stub `canPop` devuelve null y el widget tira.
    when(() => navigation.canPop(any())).thenReturn(false);
  });

  tearDown(resetInjector);

  Future<void> pumpBar(
    WidgetTester tester, {
    Widget? title,
    Widget? trailing,
    Widget? secondaryLeadingWidget,
    bool autoImplyLeading = true,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
  }) => pumpBare(
    tester,
    Scaffold(
      appBar: CustomAppBar(
        title: title,
        trailing: trailing,
        secondaryLeadingWidget: secondaryLeadingWidget,
        autoImplyLeading: autoImplyLeading,
        onBackPressed: onBackPressed,
        backgroundColor: backgroundColor,
      ),
    ),
  );

  group('boton de volver', () {
    testWidgets('no aparece si no se puede volver ni hay callback', (
      tester,
    ) async {
      await pumpBar(tester);
      expect(find.byType(CustomIcon), findsNothing);
    });

    testWidgets('aparece cuando el navigation helper puede volver', (
      tester,
    ) async {
      when(() => navigation.canPop(any())).thenReturn(true);
      await pumpBar(tester);

      expect(find.byType(CustomIcon), findsOneWidget);
    });

    testWidgets('aparece con onBackPressed aunque no se pueda volver', (
      tester,
    ) async {
      // `canGoBack` es `onBackPressed != null || canPop(context)`, con el
      // callback primero. Es lo que permite usar la app bar en una pantalla
      // raiz que igual quiere un boton de "cerrar".
      await pumpBar(tester, onBackPressed: () {});

      expect(find.byType(CustomIcon), findsOneWidget);
    });

    testWidgets('autoImplyLeading en false lo esconde', (tester) async {
      when(() => navigation.canPop(any())).thenReturn(true);
      await pumpBar(tester, autoImplyLeading: false);

      expect(find.byType(CustomIcon), findsNothing);
    });

    testWidgets('tocarlo llama onBackPressed', (tester) async {
      var backs = 0;
      await pumpBar(tester, onBackPressed: () => backs++);

      await tester.tap(find.byType(CustomIcon));
      await tester.pump();

      expect(backs, 1);
      verifyNever(() => navigation.popToPreviousRoute(any()));
    });

    testWidgets('sin onBackPressed delega en el navigation helper', (
      tester,
    ) async {
      when(() => navigation.canPop(any())).thenReturn(true);
      await pumpBar(tester);

      await tester.tap(find.byType(CustomIcon));
      await tester.pump();

      verify(() => navigation.popToPreviousRoute(any())).called(1);
    });
  });

  group('slots', () {
    testWidgets('renderiza el titulo', (tester) async {
      await pumpBar(tester, title: const Text('Mi perfil'));
      expect(find.text('Mi perfil'), findsOneWidget);
    });

    testWidgets('renderiza el trailing', (tester) async {
      await pumpBar(tester, trailing: const Icon(Icons.more_vert));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('el secondaryLeading solo se monta si hay boton de volver', (
      tester,
    ) async {
      // Vive dentro de la rama `autoImplyLeading && canGoBack`: sin boton de
      // volver no hay fila donde ponerlo.
      await pumpBar(tester, secondaryLeadingWidget: const Text('extra'));
      expect(find.text('extra'), findsNothing);

      await pumpBar(
        tester,
        onBackPressed: () {},
        secondaryLeadingWidget: const Text('extra'),
      );
      expect(find.text('extra'), findsOneWidget);
    });

    testWidgets('el fondo por defecto es transparente', (tester) async {
      await pumpBar(tester);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomAppBar),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, Colors.transparent);
    });

    testWidgets('respeta el backgroundColor', (tester) async {
      await pumpBar(tester, backgroundColor: Colors.amber);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomAppBar),
          matching: find.byType(Container),
        ),
      );
      expect(container.color, Colors.amber);
    });
  });

  group('preferredSize', () {
    test('por defecto es 40 de alto', () {
      expect(const CustomAppBar().preferredSize, const Size.fromHeight(40));
    });

    test('respeta el height que recibe', () {
      expect(
        const CustomAppBar(height: 72).preferredSize,
        const Size.fromHeight(72),
      );
    });
  });

  testWidgets('el boton de volver es un PressableWidget transparente', (
    tester,
  ) async {
    // El fondo transparente es lo que deja ver el color de la app bar detras.
    await pumpBar(tester, onBackPressed: () {});

    expect(
      tester
          .widget<PressableWidget>(find.byType(PressableWidget))
          .backgroundColor,
      Colors.transparent,
    );
  });
}
