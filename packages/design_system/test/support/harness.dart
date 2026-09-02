import 'package:commons/commons.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Prepara el binding y apaga la descarga de tipografias. Llamar como primera
/// linea de `main()` en cualquier test que arme estilos **fuera** de un
/// `testWidgets`.
///
/// `google_fonts` necesita el `ServicesBinding` para mirar los assets, y sin
/// esto el archivo entero falla con "Binding has not yet been initialized" sin
/// decir que la culpa es de la tipografia.
void initDsBinding() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// `CustomTextStyles` armada con `TextStyle` planos, uno por campo, con un
/// `fontSize` distinto derivado de [base].
///
/// **No usar `SmartWarehouseTextStyles` fuera de un `testWidgets`.** Resuelve
/// sus 19 estilos con `google_fonts` en el constructor, y con
/// `allowRuntimeFetching` en false `loadFontIfNecessary` imprime el error y
/// ademas hace `rethrow`. Como nadie awaitea ese future, en el cuerpo de
/// `main()` queda como error asincronico sin dueno y el archivo no llega ni a
/// cargar.
///
/// Los `fontSize` distintos por campo son deliberados: `CustomTextStyles.lerp`
/// y `CustomThemeExtension.copyWith` son listas de 19 lineas copiadas a mano, y
/// el bug que hay que atrapar es el campo cruzado. Con estilos iguales entre si
/// ese bug es invisible.
CustomTextStyles textStylesFixture(double base) => CustomTextStyles(
  f20W700: CustomTextStyle(TextStyle(fontSize: base + 1)),
  f14W600: CustomTextStyle(TextStyle(fontSize: base + 2)),
  f16W500: CustomTextStyle(TextStyle(fontSize: base + 3)),
  f16W600: CustomTextStyle(TextStyle(fontSize: base + 4)),
  f18W500: CustomTextStyle(TextStyle(fontSize: base + 5)),
  f24W500: CustomTextStyle(TextStyle(fontSize: base + 6)),
  f14W500: CustomTextStyle(TextStyle(fontSize: base + 7)),
  f12W700: CustomTextStyle(TextStyle(fontSize: base + 8)),
  f16W700: CustomTextStyle(TextStyle(fontSize: base + 9)),
  f12W500: CustomTextStyle(TextStyle(fontSize: base + 10)),
  f14W600PJS: CustomTextStyle(TextStyle(fontSize: base + 11)),
  f10W500: CustomTextStyle(TextStyle(fontSize: base + 12)),
  f18W700: CustomTextStyle(TextStyle(fontSize: base + 13)),
  f10W700: CustomTextStyle(TextStyle(fontSize: base + 14)),
  f8W700: CustomTextStyle(TextStyle(fontSize: base + 15)),
  f14W700PJS: CustomTextStyle(TextStyle(fontSize: base + 16)),
  f24W700: CustomTextStyle(TextStyle(fontSize: base + 17)),
  f20W500: CustomTextStyle(TextStyle(fontSize: base + 18)),
  f13W400: CustomTextStyle(TextStyle(fontSize: base + 19)),
);

/// Monta [child] dentro de un `MaterialApp` con el tema del design system y un
/// `Scaffold`, que es como lo consumen las features.
///
/// Registra la `CustomThemeExtension` en el `ThemeData` igual que
/// `lib/application/application.dart`: sin eso, `CustomThemeExtension.of` cae
/// al fallback y los tests no ejercitarían el camino que corre en la app.
Future<void> pumpDs(WidgetTester tester, Widget child) =>
    pumpBare(tester, Scaffold(body: child));

/// Igual que [pumpDs] pero sin `Scaffold`.
///
/// Lo usan los widgets que traen el suyo o que no viven en el árbol de una
/// pantalla — `CustomDialog`, que se monta sobre el `Navigator` del
/// `MaterialApp`.
Future<void> pumpBare(WidgetTester tester, Widget child) async {
  // `SwText` y `CustomTextStyles` se construyen sobre `google_fonts`, que sin
  // este flag intenta bajar las tipografías por red durante el test.
  initDsBinding();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [SmartWarehouseTheme().themeExtension]),
      home: child,
    ),
  );
  await tester.pump();
}

/// Un `AssetBundle` que responde con un PNG de 1x1 transparente a cualquier
/// clave.
///
/// `SwLogo` hace `Image.asset('assets/images/sw_logo_full.png')`, pero ese
/// asset vive en el root de la app y `design_system/pubspec.yaml` no declara
/// bloque `flutter: assets:`. Bajo test el bundle real tira
/// "Unable to load asset", el image resource service lo reporta y el caso
/// falla — no falla en silencio.
///
/// Envolver en `DefaultAssetBundle` con este bundle deja al widget montarse de
/// verdad, que es lo que hace falta para poder afirmar **que asset elige** sin
/// tragarse la excepcion con un `takeException` que taparia tambien las
/// excepciones que si importan.
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // `AssetImage.obtainKey` arranca pidiendo el manifiesto para resolver las
    // variantes por densidad. Devolverle el PNG hace explotar el decoder del
    // manifiesto antes de llegar a la imagen: va un mapa vacio, que significa
    // "sin variantes" y deja que la clave se resuelva tal cual.
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object>{})!;
    }
    return ByteData.view(Uint8List.fromList(_transparentPng).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '';
}

/// PNG valido de 1x1 transparente. El decoder de imagenes necesita bytes que
/// parseen; cualquier relleno hace fallar el codec.
const _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

/// Registra [mock] como singleton de [T] en el `Injector` global.
///
/// `design_system` no depende de `packages/test_support` a propósito (spec §7):
/// la regla de la casa es compartir un helper recién cuando lo necesitan dos
/// packages, y acá el único que toca el `Injector` es `CustomAppBar`.
T registerMock<T extends Object>(T mock) {
  Injector.i.registerSingleton<T>(mock);
  return mock;
}

/// Limpia el `Injector` global entre tests. Llamar desde `tearDown`.
///
/// El `await` no es decorativo: `clear()` descarta el `Future` de
/// `GetIt.reset()`, así que sin drenar la cola de microtasks el registro del
/// test anterior puede sobrevivir al siguiente.
Future<void> resetInjector() async {
  Injector.i.clear();
  await Future<void>.delayed(Duration.zero);
}
