import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// Construye una extension donde **cada uno de los 19 colores es distinto**,
/// derivado de [base].
///
/// Los colores distintos son el punto del helper. `copyWith` y `lerp` son 19
/// lineas casi identicas escritas a mano; el modo de falla real no es que la
/// interpolacion este mal, es el cross-wiring — `gray300: Color.lerp(gray300,
/// other.white300, t)`. Con una paleta uniforme ese bug pasa invisible.
CustomThemeExtension _ext(
  int base, {
  double styleBase = 100,
  CustomTextStyles? textStyles,
}) => CustomThemeExtension(
      textStyles: textStyles ?? textStylesFixture(styleBase),
      white10: Color(base + 1),
      darkGray: Color(base + 2),
      gray: Color(base + 3),
      primaryWhite: Color(base + 4),
      lightGray: Color(base + 5),
      primaryBlack: Color(base + 6),
      black50: Color(base + 7),
      gray300: Color(base + 8),
      white300: Color(base + 9),
      black70: Color(base + 10),
      white80: Color(base + 11),
      black10: Color(base + 12),
      white90: Color(base + 13),
      negative300: Color(base + 14),
      tertiary200: Color(base + 15),
      gray500: Color(base + 16),
      white800: Color(base + 17),
      gray200: Color(base + 18),
      black20: Color(base + 19),
    );

/// Un getter por color, para poder recorrer los 19 en vez de escribir 19
/// aserciones por caso.
final _readers = <String, Color Function(CustomThemeExtension)>{
  'white10': (e) => e.white10,
  'darkGray': (e) => e.darkGray,
  'gray': (e) => e.gray,
  'primaryWhite': (e) => e.primaryWhite,
  'lightGray': (e) => e.lightGray,
  'primaryBlack': (e) => e.primaryBlack,
  'black50': (e) => e.black50,
  'gray300': (e) => e.gray300,
  'white300': (e) => e.white300,
  'black70': (e) => e.black70,
  'white80': (e) => e.white80,
  'black10': (e) => e.black10,
  'white90': (e) => e.white90,
  'negative300': (e) => e.negative300,
  'tertiary200': (e) => e.tertiary200,
  'gray500': (e) => e.gray500,
  'white800': (e) => e.white800,
  'gray200': (e) => e.gray200,
  'black20': (e) => e.black20,
};

void main() {
  initDsBinding();

  final a = _ext(0xFF000000);
  final b = _ext(0xFF400000, styleBase: 200);

  group('lerp', () {
    test('devuelve this si el otro no es una CustomThemeExtension', () {
      // La guarda es `other is! CustomThemeExtension`, y null la cumple.
      expect(a.lerp(null, 0.5), same(a));
    });

    for (final entry in _readers.entries) {
      test('${entry.key}: t=0 conserva el origen', () {
        final result = a.lerp(b, 0) as CustomThemeExtension;
        expect(entry.value(result).toARGB32(), entry.value(a).toARGB32());
      });

      test('${entry.key}: t=1 llega al destino', () {
        final result = a.lerp(b, 1) as CustomThemeExtension;
        expect(entry.value(result).toARGB32(), entry.value(b).toARGB32());
      });

      test('${entry.key}: t=0.5 interpola contra su propio par', () {
        // Se compara contra `Color.lerp` del par correcto: si la
        // implementacion cruzara dos campos, el valor esperado no daria.
        final result = a.lerp(b, 0.5) as CustomThemeExtension;
        final expected = Color.lerp(entry.value(a), entry.value(b), 0.5)!;
        expect(entry.value(result).toARGB32(), expected.toARGB32());
      });
    }

    test('interpola tambien los textStyles', () {
      final result = a.lerp(b, 1) as CustomThemeExtension;
      expect(
        result.textStyles.f18W500.value.fontSize,
        b.textStyles.f18W500.value.fontSize,
      );
    });
  });

  group('copyWith', () {
    for (final entry in _readers.entries) {
      test('pisar ${entry.key} no toca los otros 18', () {
        const override = Color(0xFFABCDEF);
        final result = _copyOne(a, entry.key, override) as CustomThemeExtension;

        expect(
          entry.value(result).toARGB32(),
          override.toARGB32(),
          reason: '${entry.key} deberia haber quedado pisado',
        );

        for (final other in _readers.entries) {
          if (other.key == entry.key) continue;
          expect(
            other.value(result).toARGB32(),
            other.value(a).toARGB32(),
            reason: 'pisar ${entry.key} no deberia mover ${other.key}',
          );
        }
      });
    }

    test('sin argumentos devuelve una copia equivalente', () {
      final result = a.copyWith() as CustomThemeExtension;
      for (final reader in _readers.values) {
        expect(reader(result).toARGB32(), reader(a).toARGB32());
      }
      expect(result.textStyles, same(a.textStyles));
    });

    test('pisa los textStyles sin tocar los colores', () {
      final styles = textStylesFixture(500);
      final result = a.copyWith(textStyles: styles) as CustomThemeExtension;
      expect(result.textStyles, same(styles));
      expect(result.gray.toARGB32(), a.gray.toARGB32());
    });
  });

  group('of', () {
    testWidgets('devuelve la extension registrada en el ThemeData', (
      tester,
    ) async {
      // `pumpDs` registra la del SmartWarehouseTheme, que es lo que hace la app.
      late CustomThemeExtension resolved;
      await pumpDs(
        tester,
        Builder(
          builder: (context) {
            resolved = CustomThemeExtension.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(
        resolved.primaryBlack.toARGB32(),
        SmartWarehouseTheme().themeExtension.primaryBlack.toARGB32(),
      );
    });

    testWidgets('cae al SmartWarehouseTheme si no hay ninguna registrada', (
      tester,
    ) async {
      // Sin este fallback, cualquier widget del design system montado bajo un
      // ThemeData pelado tira un null check. Es el camino que corre en los
      // tests de las features que no arman el tema.
      late CustomThemeExtension resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = CustomThemeExtension.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        resolved.primaryBlack.toARGB32(),
        SmartWarehouseTheme().themeExtension.primaryBlack.toARGB32(),
      );
    });
  });
}

/// `copyWith` toma parametros nombrados, asi que no hay forma de pisar "el
/// campo N" sin este switch.
ThemeExtension<CustomThemeExtension> _copyOne(
  CustomThemeExtension source,
  String field,
  Color value,
) {
  return switch (field) {
    'white10' => source.copyWith(white10: value),
    'darkGray' => source.copyWith(darkGray: value),
    'gray' => source.copyWith(gray: value),
    'primaryWhite' => source.copyWith(primaryWhite: value),
    'lightGray' => source.copyWith(lightGray: value),
    'primaryBlack' => source.copyWith(primaryBlack: value),
    'black50' => source.copyWith(black50: value),
    'gray300' => source.copyWith(gray300: value),
    'white300' => source.copyWith(white300: value),
    'black70' => source.copyWith(black70: value),
    'white80' => source.copyWith(white80: value),
    'black10' => source.copyWith(black10: value),
    'white90' => source.copyWith(white90: value),
    'negative300' => source.copyWith(negative300: value),
    'tertiary200' => source.copyWith(tertiary200: value),
    'gray500' => source.copyWith(gray500: value),
    'white800' => source.copyWith(white800: value),
    'gray200' => source.copyWith(gray200: value),
    'black20' => source.copyWith(black20: value),
    _ => throw ArgumentError('campo desconocido: $field'),
  };
}
