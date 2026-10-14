import 'package:design_system/theme/sw_tokens.dart';
import 'package:design_system/widgets/sw_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Future<void> pumpOpener(
    WidgetTester tester, {
    required List<String?> results,
    required WidgetBuilder builder,
  }) async {
    await pumpBare(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                results.add(
                  await SwSheet.show<String>(context, builder: builder),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el contenido con handle arriba', (tester) async {
    final results = <String?>[];
    await pumpOpener(
      tester,
      results: results,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(20),
        child: Text('contenido del sheet'),
      ),
    );

    expect(find.text('contenido del sheet'), findsOneWidget);
    expect(find.byType(SwSheetHandle), findsOneWidget);
  });

  testWidgets('el pop del contenido resuelve el valor', (tester) async {
    final results = <String?>[];
    await pumpOpener(
      tester,
      results: results,
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).pop('ok!'),
        child: const Text('cerrar'),
      ),
    );

    await tester.tap(find.text('cerrar'));
    await tester.pumpAndSettle();

    expect(results, ['ok!']);
  });

  testWidgets('tocar afuera resuelve null', (tester) async {
    final results = <String?>[];
    await pumpOpener(
      tester,
      results: results,
      builder: (_) => const SizedBox(height: 120),
    );

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });

  testWidgets('fondo blanco y radio superior de marca', (tester) async {
    final results = <String?>[];
    await pumpOpener(
      tester,
      results: results,
      builder: (_) => const SizedBox(height: 80),
    );

    final sheet = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(sheet.color, SwColors.white);
    final shape = sheet.shape! as RoundedRectangleBorder;
    expect(
      shape.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(SwRadii.largeInput)),
    );
  });
}
