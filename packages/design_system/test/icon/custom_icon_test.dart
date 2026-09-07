import 'package:design_system/icon/custom_circular_icon.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../support/harness.dart';

void main() {
  group('CustomIcon', () {
    testWidgets('dimensiona el SVG con el size que recibe', (tester) async {
      await pumpDs(
        tester,
        const CustomIcon(
          data: CustomIconData.emailOutline,
          size: Size(32, 24),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 32);
      expect(svg.height, 24);
    });

    testWidgets('renderiza sin explotar el SVG inline', (tester) async {
      // Los iconos son strings de SVG en `static const`. Un `</svg>` mal
      // cerrado en uno de ellos solo se descubre montandolo.
      await pumpDs(
        tester,
        const CustomIcon(
          data: CustomIconData.leftSquareArrow,
          size: Size(28, 28),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('sin color no tinta el SVG', (tester) async {
      await pumpDs(
        tester,
        const CustomIcon(
          data: CustomIconData.emailOutline,
          size: Size(24, 24),
        ),
      );

      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        isNull,
      );
    });

    testWidgets('con color aplica un colorFilter', (tester) async {
      await pumpDs(
        tester,
        const CustomIcon(
          data: CustomIconData.emailOutline,
          size: Size(24, 24),
          color: Colors.red,
        ),
      );

      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        isNotNull,
      );
    });
  });

  group('CustomCircularIcon', () {
    testWidgets('envuelve el icono en el contenedor del tema', (tester) async {
      late CustomThemeExtension theme;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            theme = CustomThemeExtension.of(context);
            return const CustomCircularIcon(
              iconData: CustomIconData.emailOutline,
            );
          },
        ),
      );

      final decoration =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(CustomCircularIcon),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;

      expect(decoration.color, theme.primaryWhite);
      expect((decoration.border! as Border).top.color, theme.black10);
    });

    testWidgets('el icono de adentro mide 32', (tester) async {
      await pumpDs(
        tester,
        const CustomCircularIcon(iconData: CustomIconData.emailOutline),
      );

      expect(
        tester.widget<CustomIcon>(find.byType(CustomIcon)).size,
        const Size(32, 32),
      );
    });
  });
}
