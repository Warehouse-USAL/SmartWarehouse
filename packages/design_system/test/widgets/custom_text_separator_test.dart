import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/custom_text_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('renderiza el texto entre dos divisores', (tester) async {
    await pumpDs(tester, const CustomTextSeparator(text: 'OR'));

    expect(find.text('OR'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('los divisores usan el black50 del tema', (tester) async {
    late CustomThemeExtension theme;
    await pumpDs(
      tester,
      Builder(
        builder: (context) {
          theme = CustomThemeExtension.of(context);
          return const CustomTextSeparator(text: 'OR');
        },
      ),
    );

    for (final divider in tester.widgetList<Divider>(find.byType(Divider))) {
      expect(divider.color, theme.black50);
    }
  });

  testWidgets('el estilo por defecto es f16W500', (tester) async {
    late CustomTextStyles styles;
    await pumpDs(
      tester,
      Builder(
        builder: (context) {
          styles = CustomTextStyles.of(context);
          return const CustomTextSeparator(text: 'OR');
        },
      ),
    );

    expect(
      tester.widget<Text>(find.text('OR')).style!.fontSize,
      styles.f16W500.value.fontSize,
    );
  });

  testWidgets('acepta un styleBuilder propio', (tester) async {
    // El widget hace `styleBuilder ?? (styles) => styles.f16W500`. Sin el
    // `??` el parametro seria decorativo.
    late CustomTextStyles styles;
    await pumpDs(
      tester,
      Builder(
        builder: (context) {
          styles = CustomTextStyles.of(context);
          return CustomTextSeparator(
            text: 'OR',
            styleBuilder: (s) => s.f24W700,
          );
        },
      ),
    );

    expect(
      tester.widget<Text>(find.text('OR')).style!.fontSize,
      styles.f24W700.value.fontSize,
    );
  });
}
