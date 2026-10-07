import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// `SwText` no toca el arbol de widgets: son cuatro funciones que devuelven un
/// `TextStyle`. Aun asi los casos son `testWidgets` y **no** `test`, a
/// proposito.
///
/// Cada helper llama a `GoogleFonts.<familia>()`, que dispara
/// `loadFontIfNecessary`. Con `allowRuntimeFetching` en false y la fuente
/// ausente de los assets, esa funcion imprime el error y ademas hace
/// `rethrow`. Nadie awaitea ese future, asi que queda como error asincronico
/// sin dueno: dentro de un `test` package:test se lo atribuye al caso y lo
/// marca fallado; dentro de un `testWidgets` el binding lo absorbe.
///
/// Convertirlos a `test` "porque no usan el tester" rompe los once casos.
void main() {
  initDsBinding();

  // Lo unico con logica en `SwText` es que `letterSpacing` no es el valor que
  // recibe: es `letterSpacing * size`, porque el spec de marca lo define en
  // ems y Flutter lo quiere en pixeles. Es la linea que se rompe si alguien
  // "simplifica" el helper, y no la detecta ningun test de layout.
  group('SwText.display', () {
    testWidgets('convierte el letterSpacing de ems a pixeles', (tester) async {
      expect(SwText.display(size: 20).letterSpacing, 20 * -0.02);
    });

    testWidgets('respeta un letterSpacing explicito, tambien escalado', (
      tester,
    ) async {
      expect(
        SwText.display(size: 30, letterSpacing: 0.1).letterSpacing,
        closeTo(3, 1e-9),
      );
    });

    testWidgets('aplica size, weight, color y height', (tester) async {
      final style = SwText.display(
        size: 28,
        weight: FontWeight.w900,
        color: SwColors.link,
        height: 1.2,
      );

      expect(style.fontSize, 28);
      expect(style.fontWeight, FontWeight.w900);
      expect(style.color, SwColors.link);
      expect(style.height, 1.2);
    });

    testWidgets('por defecto pesa w700 y pinta con SwColors.text', (
      tester,
    ) async {
      final style = SwText.display(size: 16);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, SwColors.text);
    });
  });

  group('SwText.body', () {
    testWidgets('escala el letterSpacing con el size por defecto', (
      tester,
    ) async {
      expect(SwText.body().letterSpacing, 15 * -0.005);
      expect(SwText.body().fontSize, 15);
    });

    testWidgets('el size override tambien mueve el letterSpacing', (
      tester,
    ) async {
      expect(SwText.body(size: 30).letterSpacing, 30 * -0.005);
    });

    testWidgets('acepta weight, color y height', (tester) async {
      final style = SwText.body(
        weight: FontWeight.w700,
        color: SwColors.stockOut,
        height: 1.4,
      );

      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, SwColors.stockOut);
      expect(style.height, 1.4);
    });
  });

  group('SwText.label', () {
    testWidgets('usa los defaults del design system', (tester) async {
      final style = SwText.label();
      expect(style.fontSize, 13);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, SwColors.text2);
    });

    testWidgets('no escala nada: no tiene letterSpacing', (tester) async {
      expect(SwText.label(size: 40).letterSpacing, isNull);
    });
  });

  group('SwText.mono', () {
    testWidgets('escala el letterSpacing con el size', (tester) async {
      expect(SwText.mono(size: 20).letterSpacing, closeTo(1, 1e-9));
    });

    testWidgets('defaults: 10px sobre SwColors.text3', (tester) async {
      final style = SwText.mono();
      expect(style.fontSize, 10);
      expect(style.color, SwColors.text3);
    });
  });
}
