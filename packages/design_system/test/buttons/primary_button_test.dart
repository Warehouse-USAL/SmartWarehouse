import 'package:design_system/buttons/primary_button.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  PressableWidget pressableOf(WidgetTester tester) =>
      tester.widget<PressableWidget>(find.byType(PressableWidget));

  group('onPressed', () {
    testWidgets('dispara el callback al tocarse', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        PrimaryButton(text: 'Continuar', onPressed: () => taps++),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('isLoading corta el onPressed', (tester) async {
      // `onPressed: isLoading ? null : onPressed`. Es la unica defensa contra
      // el doble submit: el boton se sigue viendo, pero deja de responder.
      var taps = 0;
      await pumpDs(
        tester,
        PrimaryButton(
          text: 'Continuar',
          isLoading: true,
          onPressed: () => taps++,
        ),
      );

      expect(pressableOf(tester).onPressed, isNull);

      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);
    });

    testWidgets('sin onPressed queda deshabilitado', (tester) async {
      await pumpDs(tester, const PrimaryButton(text: 'Continuar'));
      expect(pressableOf(tester).onPressed, isNull);
    });
  });

  group('isLoading', () {
    testWidgets('cambia el texto por el spinner', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(text: 'Continuar', isLoading: true),
      );

      expect(find.text('Continuar'), findsNothing);
      expect(find.byType(SwLoadingSpinner), findsOneWidget);
    });

    testWidgets('esconde los iconos', (tester) async {
      // Los cuatro slots (leading, trailing, y sus variantes de icono) llevan
      // `&& !isLoading`. Uno solo que se olvide deja el icono flotando al lado
      // del spinner.
      await pumpDs(
        tester,
        const PrimaryButton(
          text: 'Continuar',
          isLoading: true,
          leadingIconData: CustomIconData.googleIcon,
          trailingIconData: CustomIconData.appleIcon,
        ),
      );

      expect(find.byType(CustomIcon), findsNothing);
    });

    testWidgets('esconde los widgets leading y trailing', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(
          text: 'Continuar',
          isLoading: true,
          leading: Text('L'),
          trailing: Text('T'),
        ),
      );

      expect(find.text('L'), findsNothing);
      expect(find.text('T'), findsNothing);
    });
  });

  group('slots', () {
    testWidgets('renderiza el texto', (tester) async {
      await pumpDs(
        tester,
        PrimaryButton(text: 'Continuar', onPressed: () {}),
      );

      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets('leadingIconData monta un CustomIcon', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(
          text: 'Continuar',
          leadingIconData: CustomIconData.googleIcon,
        ),
      );

      expect(find.byType(CustomIcon), findsOneWidget);
    });

    testWidgets('leadingIconData gana sobre leading', (tester) async {
      // La guarda de `leading` es `leadingIconData == null`. Pasar los dos es
      // legal y solo uno se dibuja.
      await pumpDs(
        tester,
        const PrimaryButton(
          text: 'Continuar',
          leadingIconData: CustomIconData.googleIcon,
          leading: Text('L'),
        ),
      );

      expect(find.byType(CustomIcon), findsOneWidget);
      expect(find.text('L'), findsNothing);
    });

    testWidgets('leading solo se monta sin leadingIconData', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(text: 'Continuar', leading: Text('L')),
      );

      expect(find.text('L'), findsOneWidget);
    });

    testWidgets('trailingIconData gana sobre trailing', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(
          text: 'Continuar',
          trailingIconData: CustomIconData.appleIcon,
          trailing: Text('T'),
        ),
      );

      expect(find.byType(CustomIcon), findsOneWidget);
      expect(find.text('T'), findsNothing);
    });
  });

  group('estilo', () {
    testWidgets('sin tema usa el primaryWhite del design system', (
      tester,
    ) async {
      late CustomThemeExtension theme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            theme = CustomThemeExtension.of(context);
            return const PrimaryButton(text: 'Continuar');
          },
        ),
      );

      expect(
        tester.widget<CustomText>(find.byType(CustomText)).color,
        theme.primaryWhite,
      );
    });

    testWidgets('textColor pisa el color por defecto', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(text: 'Continuar', textColor: Colors.orange),
      );

      expect(
        tester.widget<CustomText>(find.byType(CustomText)).color,
        Colors.orange,
      );
    });

    testWidgets('backgroundColor llega al PressableWidget', (tester) async {
      await pumpDs(
        tester,
        const PrimaryButton(text: 'Continuar', backgroundColor: Colors.teal),
      );

      expect(pressableOf(tester).backgroundColor, Colors.teal);
    });

    testWidgets('respeta height y width', (tester) async {
      // 300 y no 200: el `Row` interno no tiene `Expanded`, asi que con el
      // padding de 22 por lado un ancho justo hace overflowear el texto y el
      // caso falla por layout en vez de por el `SizedBox`.
      await pumpDs(
        tester,
        const PrimaryButton(text: 'Continuar', height: 60, width: 300),
      );

      expect(
        tester.getSize(find.byType(PrimaryButton)),
        const Size(300, 60),
      );
    });

    testWidgets('un border explicito le gana al del BaseButtonTheme', (
      tester,
    ) async {
      // La expresion es `border ?? (baseButtonTheme?.borderColor != null ...)`.
      // Sin el `??` primero, el borde del theme pisaria al que pide el
      // llamador.
      const explicit = Border(top: BorderSide(color: Colors.pink));
      await pumpDs(
        tester,
        Builder(
          builder: (context) => PrimaryButton(
            text: 'Continuar',
            border: explicit,
            baseButtonTheme: BaseButtonTheme.secondary(context),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PrimaryButton),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration! as BoxDecoration).border, explicit);
    });
  });

  group('BaseButtonTheme', () {
    testWidgets('primary no dibuja borde', (tester) async {
      late BaseButtonTheme theme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            theme = BaseButtonTheme.primary(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(theme.hasBorder, isFalse);
      expect(theme.borderColor, isNull);
    });

    testWidgets('secondary si dibuja borde', (tester) async {
      late BaseButtonTheme theme;
      late CustomThemeExtension extension;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            extension = CustomThemeExtension.of(context);
            theme = BaseButtonTheme.secondary(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(theme.hasBorder, isTrue);
      expect(theme.borderColor, extension.black50);
      expect(theme.backgroundColor, extension.primaryWhite);
    });

    testWidgets('secondary engrosa el texto a w700', (tester) async {
      // `style.f18W500.value.copyWith(fontWeight: FontWeight.w700)`. El nombre
      // del token dice W500 y el theme lo pisa: sin este caso, alguien
      // "corrige" el copyWith creyendo que es un error de tipeo.
      late BaseButtonTheme theme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            theme = BaseButtonTheme.secondary(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(theme.textButtonStyle!.fontWeight, FontWeight.w700);
    });

    testWidgets('copyWith pisa solo lo que recibe', (tester) async {
      late BaseButtonTheme base;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            base = BaseButtonTheme.primary(context);
            return const SizedBox.shrink();
          },
        ),
      );

      final copy = base.copyWith(backgroundColor: Colors.red);

      expect(copy.backgroundColor, Colors.red);
      expect(copy.textColor, base.textColor);
      expect(copy.pressedColor, base.pressedColor);
      expect(copy.disabledBackgroundColor, base.disabledBackgroundColor);
    });

    testWidgets('copyWith sin argumentos devuelve un equivalente', (
      tester,
    ) async {
      late BaseButtonTheme base;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            base = BaseButtonTheme.secondary(context);
            return const SizedBox.shrink();
          },
        ),
      );

      final copy = base.copyWith();

      expect(copy.backgroundColor, base.backgroundColor);
      expect(copy.borderColor, base.borderColor);
      expect(copy.textButtonStyle, base.textButtonStyle);
    });

    testWidgets('el theme manda el color de texto sobre textColor', (
      tester,
    ) async {
      // El orden es `baseButtonTheme?.textColor ?? textColor ?? theme...`.
      await pumpDs(
        tester,
        Builder(
          builder: (context) => PrimaryButton(
            text: 'Continuar',
            textColor: Colors.orange,
            baseButtonTheme: BaseButtonTheme.primary(context),
          ),
        ),
      );

      expect(
        tester.widget<CustomText>(find.byType(CustomText)).color,
        isNot(Colors.orange),
      );
    });

    testWidgets('styleBuilder desactiva el estilo del theme', (tester) async {
      // `style: styleBuilder == null ? baseButtonTheme?.textButtonStyle : null`
      // y el `styleBuilder` propio gana. Pasar los dos sin esta rama dispararia
      // el assert de `CustomText`... o peor, aplicaria el equivocado.
      late CustomTextStyles styles;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            styles = CustomTextStyles.of(context);
            return PrimaryButton(
              text: 'Continuar',
              styleBuilder: (s) => s.f24W700,
              baseButtonTheme: BaseButtonTheme.secondary(context),
            );
          },
        ),
      );

      expect(
        tester.widget<Text>(find.text('Continuar')).style!.fontSize,
        styles.f24W700.value.fontSize,
      );
    });
  });
}
