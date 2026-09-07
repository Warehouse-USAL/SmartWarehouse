import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

void main() {
  testWidgets('renderiza el mensaje que recibe', (tester) async {
    await pumpDs(
      tester,
      SwErrorView(message: 'No pudimos cargar el catalogo', onRetry: () {}),
    );

    expect(find.text('No pudimos cargar el catalogo'), findsOneWidget);
  });

  testWidgets('Reintentar invoca onRetry', (tester) async {
    // El label del boton esta hardcodeado en el widget: es el unico camino de
    // salida de una pantalla en error, y si el callback no se cablea la
    // pantalla queda muerta sin que nada falle.
    var retries = 0;
    await pumpDs(
      tester,
      SwErrorView(message: 'Falló', onRetry: () => retries++),
    );

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('se dibuja como variante secundaria', (tester) async {
    await pumpDs(tester, SwErrorView(message: 'Falló', onRetry: () {}));

    expect(
      tester.widget<SwButton>(find.byType(SwButton)).variant,
      SwButtonVariant.secondary,
    );
  });

  testWidgets('muestra el icono de error', (tester) async {
    await pumpDs(tester, SwErrorView(message: 'Falló', onRetry: () {}));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
