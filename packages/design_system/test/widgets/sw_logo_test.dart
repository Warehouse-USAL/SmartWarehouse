import 'package:design_system/widgets/sw_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

/// `SwLogo` llama `Image.asset('assets/images/...')`, pero ese asset vive en el
/// root de la app y `design_system/pubspec.yaml` no declara bloque
/// `flutter: assets:`. Contra el bundle real la carga tira "Unable to load
/// asset" y el caso falla, asi que los tests montan el widget bajo un
/// `DefaultAssetBundle` con [TestAssetBundle].
///
/// Las aserciones son sobre **que asset elige** y **que anuncia a
/// accesibilidad**, no sobre el pixel renderizado: eso es lo unico que el
/// widget realmente decide.
void main() {
  Future<void> pumpLogo(WidgetTester tester, Widget logo) => pumpDs(
    tester,
    DefaultAssetBundle(bundle: TestAssetBundle(), child: logo),
  );

  AssetImage assetOf(WidgetTester tester) =>
      tester.widget<Image>(find.byType(Image)).image as AssetImage;

  group('SwLogo', () {
    testWidgets('por defecto usa el logo completo', (tester) async {
      await pumpLogo(tester, const SwLogo());
      expect(assetOf(tester).assetName, 'assets/images/sw_logo_full.png');
    });

    testWidgets('markOnly usa solo el isotipo', (tester) async {
      await pumpLogo(tester, const SwLogo(markOnly: true));
      expect(assetOf(tester).assetName, 'assets/images/sw_logo_mark.png');
    });

    testWidgets('se anuncia como imagen con el nombre de la marca', (
      tester,
    ) async {
      await pumpLogo(tester, const SwLogo());

      final semantics = tester.getSemantics(find.byType(SwLogo));
      // `getSemantics` devuelve el nodo mergeado, que separa los labels de los
      // hijos con saltos de linea; de ahi el trim.
      expect(semantics.label.trim(), 'SmartWarehouse');
    });

    testWidgets('la altura por defecto es 36', (tester) async {
      await pumpLogo(tester, const SwLogo());
      expect(tester.widget<Image>(find.byType(Image)).height, 36);
    });

    testWidgets('respeta el size que recibe', (tester) async {
      await pumpLogo(tester, const SwLogo(size: 56));
      expect(tester.widget<Image>(find.byType(Image)).height, 56);
    });
  });

  group('SwLogoMark', () {
    testWidgets('encuadra el isotipo en un cuadrado del size dado', (
      tester,
    ) async {
      await pumpLogo(tester, const SwLogoMark(size: 48));

      expect(tester.getSize(find.byType(SwLogoMark)), const Size(48, 48));
    });

    testWidgets('siempre pide el asset del isotipo', (tester) async {
      // `SwLogoMark` monta `SwLogo(markOnly: true)` sin pasarle el size: el
      // encuadre lo hace el `SizedBox` de afuera. Es facil "arreglarlo"
      // pasando el size y romper la proporcion.
      await pumpLogo(tester, const SwLogoMark(size: 48));

      expect(assetOf(tester).assetName, 'assets/images/sw_logo_mark.png');
    });
  });
}
