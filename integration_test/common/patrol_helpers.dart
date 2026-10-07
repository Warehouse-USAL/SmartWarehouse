import 'package:catalog/catalog.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:smart_warehouse/main.dart' as app;

import 'config.dart';

/// Bootea la app real y espera a que pase el splash y se estabilice la
/// primera pantalla. El timer del splash se anula corriendo con
/// `--dart-define=SPLASH_MS=0` (ya incluido en `make e2e`); si se corre sin
/// ese define, el timer default es de 3s y acá se espera lo que corresponda.
Future<void> bootApp(PatrolIntegrationTester $) async {
  const splashMs = int.fromEnvironment('SPLASH_MS', defaultValue: 3000);
  await app.main();
  // pumpAndTrySettle: el WS de notificaciones puede dejar timers vivos y
  // pumpAndSettle plano hace timeout de forma flaky.
  await $.pumpAndTrySettle();
  if (splashMs > 0) {
    await Future<void>.delayed(const Duration(milliseconds: splashMs + 500));
  }
  await $.pumpAndTrySettle();
}

/// True si estamos parados en el login (sesión no persistida).
bool isOnLogin(PatrolIntegrationTester $) =>
    find.byKey(E2eKeys.loginSubmitButton).evaluate().isNotEmpty;

/// Hace login con las credenciales dadas (por defecto las de E2eConfig).
Future<void> login(
  PatrolIntegrationTester $, {
  String email = E2eConfig.email,
  String password = E2eConfig.password,
}) async {
  await $(E2eKeys.loginEmailField).enterText(email);
  await $(E2eKeys.loginPasswordField).enterText(password);
  await $(E2eKeys.loginSubmitButton).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 20));
}

/// Bootea y garantiza sesión iniciada (si había sesión persistida, la reusa).
Future<void> bootAndLogin(PatrolIntegrationTester $) async {
  await bootApp($);
  if (isOnLogin($)) {
    await login($);
  }
  // Catálogo visible = login OK.
  await $(E2eKeys.navCatalogTab).waitUntilVisible();
}

/// Cierra sesión desde el perfil. Asume sesión iniciada.
Future<void> logout(PatrolIntegrationTester $) async {
  await $(E2eKeys.navProfileTab).tap();
  await $.pumpAndSettle();
  await $(E2eKeys.profileLogoutButton).scrollTo().tap();
  await $.pumpAndSettle();
}

/// Descarta snackbars pendientes (las notificaciones por WebSocket pueden
/// tapar botones durante los taps).
Future<void> dismissSnackbars(PatrolIntegrationTester $) async {
  final messengers = $.tester.stateList<ScaffoldMessengerState>(find.byType(ScaffoldMessenger));
  for (final state in messengers) {
    state.clearSnackBars();
  }
  await $.pump();
}

// ---------------------------------------------------------------------------
// Precios: parsing del formato de display de Money (`$49.999` / `$49.999,90`).
// Todas las aserciones de consistencia de moneda comparan (símbolo, centavos)
// parseados, no solo strings, para atrapar diferencias de moneda o formato.
// ---------------------------------------------------------------------------

final RegExp priceFormat = RegExp(r'^\$\d{1,3}(\.\d{3})*(,\d{2})?$');

/// Parsea un precio con el formato de `Money.formatted` a centavos.
/// Lanza si el string no respeta el formato (moneda/formato inconsistente).
int parsePriceToCents(String raw) {
  expect(
    priceFormat.hasMatch(raw),
    isTrue,
    reason: 'Precio "$raw" no respeta el formato \$1.234,56 de Money.formatted '
        '(posible inconsistencia de moneda/formato)',
  );
  final noSymbol = raw.substring(1);
  final parts = noSymbol.split(',');
  final whole = int.parse(parts[0].replaceAll('.', ''));
  final cents = parts.length > 1 ? int.parse(parts[1]) : 0;
  return whole * 100 + cents;
}

/// Devuelve el texto del `Text` con la key dada.
String textOf(PatrolIntegrationTester $, Key key) {
  final widget = $.tester.widget<Text>(find.byKey(key));
  return widget.data ?? '';
}

/// Extrae el precio (string) de un precio embebido en un label tipo
/// `Agregar al pedido · $1.234,56` o `Total: $1.234,56`.
String extractEmbeddedPrice(String label) {
  final match = RegExp(r'\$\d{1,3}(\.\d{3})*(,\d{2})?').firstMatch(label);
  expect(match, isNotNull, reason: 'No se encontró un precio en "$label"');
  return match!.group(0)!;
}

/// Primer ProductCard visible del catálogo. Devuelve el id del producto,
/// derivado de la key `e2e_product_card_<id>`.
String firstVisibleProductId(PatrolIntegrationTester $) {
  final cards = find.byType(ProductCard).evaluate();
  expect(cards, isNotEmpty, reason: 'El catálogo no muestra productos');
  final key = cards.first.widget.key;
  expect(key, isA<ValueKey<String>>());
  return (key as ValueKey<String>).value.replaceFirst('e2e_product_card_', '');
}
