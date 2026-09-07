import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

final _readers = <String, CustomTextStyle Function(CustomTextStyles)>{
  'f20W700': (s) => s.f20W700,
  'f14W600': (s) => s.f14W600,
  'f16W500': (s) => s.f16W500,
  'f16W600': (s) => s.f16W600,
  'f18W500': (s) => s.f18W500,
  'f24W500': (s) => s.f24W500,
  'f14W500': (s) => s.f14W500,
  'f12W700': (s) => s.f12W700,
  'f16W700': (s) => s.f16W700,
  'f12W500': (s) => s.f12W500,
  'f14W600PJS': (s) => s.f14W600PJS,
  'f10W500': (s) => s.f10W500,
  'f18W700': (s) => s.f18W700,
  'f10W700': (s) => s.f10W700,
  'f8W700': (s) => s.f8W700,
  'f14W700PJS': (s) => s.f14W700PJS,
  'f24W700': (s) => s.f24W700,
  'f20W500': (s) => s.f20W500,
  'f13W400': (s) => s.f13W400,
};

void main() {
  initDsBinding();

  // Cada campo trae un `fontSize` distinto: ver `textStylesFixture`. Es lo que
  // hace que cruzar dos campos en `lerp` rompa el test.
  final a = textStylesFixture(100);
  final b = textStylesFixture(200);

  group('CustomTextStyles.lerp', () {
    for (final entry in _readers.entries) {
      test('${entry.key}: t=0 conserva el origen', () {
        final result = CustomTextStyles.lerp(a, b, 0)!;
        expect(
          entry.value(result).value.fontSize,
          entry.value(a).value.fontSize,
        );
      });

      test('${entry.key}: t=1 llega al destino', () {
        final result = CustomTextStyles.lerp(a, b, 1)!;
        expect(
          entry.value(result).value.fontSize,
          entry.value(b).value.fontSize,
        );
      });
    }

    test('t=0.5 cae en el medio de cada par', () {
      final result = CustomTextStyles.lerp(a, b, 0.5)!;
      for (final entry in _readers.entries) {
        final from = entry.value(a).value.fontSize!;
        final to = entry.value(b).value.fontSize!;
        expect(
          entry.value(result).value.fontSize,
          (from + to) / 2,
          reason: entry.key,
        );
      }
    });
  });

  group('CustomTextStyle.lerp', () {
    test('interpola el TextStyle envuelto', () {
      final result = CustomTextStyle.lerp(
        CustomTextStyle(const TextStyle(fontSize: 10)),
        CustomTextStyle(const TextStyle(fontSize: 20)),
        0.5,
      )!;

      expect(result.value.fontSize, 15);
    });
  });

  group('CustomTextStyles.of', () {
    testWidgets('resuelve los estilos de la extension del tema', (
      tester,
    ) async {
      late CustomTextStyles resolved;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            resolved = CustomTextStyles.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(resolved, isA<SmartWarehouseTextStyles>());
    });
  });
}
