import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';

/// E8.3.9 — sesión persistida: relanzar la app con una sesión previa entra
/// directo al catálogo sin pedir login (cubre la persistencia en Hive y el
/// refresh del token).
///
/// Patrol limpia los datos del paquete ENTRE tests, así que el relanzamiento
/// se hace dentro del mismo test: login, segundo boot, y la segunda instancia
/// tiene que arrancar ya autenticada.
void main() {
  patrolTest('con sesión previa la app entra directo al catálogo', ($) async {
    await bootAndLogin($);

    // Segundo lanzamiento en el mismo test: la sesión quedó en Hive.
    await bootApp($);

    expect(
      isOnLogin($),
      isFalse,
      reason: 'La sesión no se persistió: el segundo boot volvió al login.',
    );
    await $(E2eKeys.navCatalogTab).waitUntilVisible();
  });
}
