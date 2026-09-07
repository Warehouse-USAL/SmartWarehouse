import 'package:design_system/widgets/sw_img_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  /// El widget se monta con tamano fijo: `Positioned.fill` dentro de un `Stack`
  /// sin restricciones no tiene con que dimensionarse.
  Future<void> pumpPlaceholder(
    WidgetTester tester, {
    String? label,
    String? imageUrl,
    bool tinted = false,
  }) => pumpDs(
    tester,
    SizedBox(
      width: 200,
      height: 120,
      child: SwImgPlaceholder(
        label: label,
        imageUrl: imageUrl,
        tinted: tinted,
      ),
    ),
  );

  group('rayas vs imagen', () {
    testWidgets('sin imageUrl dibuja las rayas', (tester) async {
      await pumpPlaceholder(tester);

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('con imageUrl vacia tambien dibuja rayas', (tester) async {
      // La guarda es `imageUrl != null && imageUrl!.isNotEmpty`. Un producto
      // sin foto suele llegar con '' desde el back, no con null: sin el
      // `isNotEmpty` se monta un `Image.network('')` que tira.
      await pumpPlaceholder(tester, imageUrl: '');

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('con imageUrl monta un Image.network', (tester) async {
      await pumpPlaceholder(tester, imageUrl: 'https://example.com/a.png');
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('si la imagen falla cae de nuevo a las rayas', (tester) async {
      // El `HttpClient` de `flutter_test` responde 400 a todo, asi que el
      // `errorBuilder` se dispara solo: no hace falta mockear la red. Esa es
      // justamente la rama que corre en produccion con una URL rota.
      await pumpPlaceholder(tester, imageUrl: 'https://example.com/rota.png');
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('label', () {
    testWidgets('sin label no monta texto', (tester) async {
      await pumpPlaceholder(tester);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('lo renderiza en mayusculas', (tester) async {
      // El widget hace `label!.toUpperCase()`: la etiqueta es un chip de SKU y
      // el design system la quiere siempre en caja alta, venga como venga.
      await pumpPlaceholder(tester, label: 'sku-0042');

      expect(find.text('SKU-0042'), findsOneWidget);
      expect(find.text('sku-0042'), findsNothing);
    });

    testWidgets('un label ya en mayusculas queda igual', (tester) async {
      await pumpPlaceholder(tester, label: 'SKU-1');
      expect(find.text('SKU-1'), findsOneWidget);
    });
  });

  group('StripePainter', () {
    /// `_StripePainter` es privado, asi que no hay tipo al que castear: se lo
    /// busca por ser el unico `CustomPaint` con painter dentro del widget.
    CustomPainter stripePainterOf(WidgetTester tester) => tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(SwImgPlaceholder),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((c) => c.painter)
        .whereType<CustomPainter>()
        .single;

    testWidgets('repinta solo si cambia el tinte', (tester) async {
      // `shouldRepaint` es `old.tinted != tinted`. Devolver siempre false
      // congela el placeholder en su primer color cuando la variante cambia.
      await pumpPlaceholder(tester);
      final plain = stripePainterOf(tester);

      await pumpPlaceholder(tester, tinted: true);
      final tinted = stripePainterOf(tester);

      expect(tinted.shouldRepaint(plain), isTrue);
      expect(tinted.shouldRepaint(tinted), isFalse);
      expect(plain.shouldRepaint(plain), isFalse);
    });

    testWidgets('pinta sin explotar en las dos variantes', (tester) async {
      // `paint` recorre la diagonal en pasos de 20px dibujando paths. Es el
      // unico codigo del package que toca el `Canvas` directo.
      await pumpPlaceholder(tester);
      expect(tester.takeException(), isNull);

      await pumpPlaceholder(tester, tinted: true);
      expect(tester.takeException(), isNull);
    });
  });
}
