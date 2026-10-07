import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/config.dart';
import 'common/patrol_helpers.dart';

void main() {
  patrolTest('login con credenciales inválidas muestra error', ($) async {
    await bootApp($);
    if (!isOnLogin($)) {
      await logout($);
    }
    await login($, email: E2eConfig.invalidEmail, password: E2eConfig.invalidPassword);
    await $(E2eKeys.loginErrorBanner).waitUntilVisible();
    // Seguimos en el login.
    expect(isOnLogin($), isTrue);
  });

  patrolTest('login con credenciales válidas llega al catálogo', ($) async {
    await bootApp($);
    if (!isOnLogin($)) {
      await logout($);
    }
    await login($);
    await $(E2eKeys.navCatalogTab).waitUntilVisible();
  });
}
