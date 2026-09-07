import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  Text renderedOf(WidgetTester tester) =>
      tester.widget<Text>(find.byType(Text));

  group('assert del constructor', () {
    test('salta si no hay ni style ni styleBuilder', () {
      // El widget resuelve `style ?? styleBuilder?.call(...)`. Sin ninguno de
      // los dos el texto se renderiza sin estilo y hereda el del tema de
      // Material, que no es el del design system: el assert lo convierte en un
      // error de desarrollo en vez de un bug visual silencioso.
      expect(() => CustomText('hola'), throwsAssertionError);
    });

    test('alcanza con style', () {
      expect(
        () => CustomText('hola', style: const TextStyle()),
        returnsNormally,
      );
    });

    test('alcanza con styleBuilder', () {
      expect(
        () => CustomText('hola', styleBuilder: (s) => s.f16W500),
        returnsNormally,
      );
    });
  });

  group('resolucion del estilo', () {
    testWidgets('style directo gana sobre styleBuilder', (tester) async {
      // El `??` evalua `style` primero. Pasar los dos es lo que hace
      // `PrimaryButton` cuando el `BaseButtonTheme` trae su propio estilo.
      await pumpDs(
        tester,
        CustomText(
          'hola',
          style: const TextStyle(fontSize: 99),
          styleBuilder: (s) => s.f16W500,
        ),
      );

      expect(renderedOf(tester).style!.fontSize, 99);
    });

    testWidgets('styleBuilder resuelve contra los estilos del tema', (
      tester,
    ) async {
      late CustomTextStyles fromTheme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            fromTheme = CustomTextStyles.of(context);
            return CustomText('hola', styleBuilder: (s) => s.f24W700);
          },
        ),
      );

      expect(
        renderedOf(tester).style!.fontSize,
        fromTheme.f24W700.value.fontSize,
      );
    });
  });

  group('useLineHeight', () {
    testWidgets('por defecto conserva el height del estilo', (tester) async {
      await pumpDs(
        tester,
        CustomText('hola', style: const TextStyle(height: 2)),
      );

      expect(renderedOf(tester).style!.height, 2);
    });

    testWidgets('en false lo fuerza a 1', (tester) async {
      // `copyWith(height: useLineHeight ? null : 1)`. El `null` en `copyWith`
      // no borra: conserva. Por eso el default deja pasar el height del estilo
      // y solo el `false` lo pisa.
      await pumpDs(
        tester,
        CustomText(
          'hola',
          style: const TextStyle(height: 2),
          useLineHeight: false,
        ),
      );

      expect(renderedOf(tester).style!.height, 1);
    });
  });

  group('overrides', () {
    testWidgets('color pisa el del estilo', (tester) async {
      await pumpDs(
        tester,
        CustomText(
          'hola',
          style: const TextStyle(color: Colors.green),
          color: Colors.red,
        ),
      );

      expect(renderedOf(tester).style!.color, Colors.red);
    });

    testWidgets('sin color explicito el estilo queda sin color', (
      tester,
    ) async {
      // `copyWith(color: color)` con `color` null tampoco borra: el estilo
      // base sobrevive.
      await pumpDs(
        tester,
        CustomText('hola', style: const TextStyle(color: Colors.green)),
      );

      expect(renderedOf(tester).style!.color, Colors.green);
    });

    testWidgets('el overflow por defecto es clip', (tester) async {
      await pumpDs(tester, CustomText('hola', style: const TextStyle()));
      expect(renderedOf(tester).overflow, TextOverflow.clip);
    });

    testWidgets('el align por defecto es left', (tester) async {
      await pumpDs(tester, CustomText('hola', style: const TextStyle()));
      expect(renderedOf(tester).textAlign, TextAlign.left);
    });

    testWidgets('propaga textAlign, textOverflow y maxLines', (tester) async {
      await pumpDs(
        tester,
        CustomText(
          'hola',
          style: const TextStyle(),
          textAlign: TextAlign.center,
          textOverflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      );

      final rendered = renderedOf(tester);
      expect(rendered.textAlign, TextAlign.center);
      expect(rendered.overflow, TextOverflow.ellipsis);
      expect(rendered.maxLines, 2);
    });

    testWidgets('renderiza el texto que recibe', (tester) async {
      await pumpDs(tester, CustomText('Bienvenido', style: const TextStyle()));
      expect(find.text('Bienvenido'), findsOneWidget);
    });
  });
}
