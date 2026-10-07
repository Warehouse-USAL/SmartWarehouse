import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';

void main() {
  patrolTest('el perfil muestra la sesión y permite cerrar sesión', ($) async {
    await bootAndLogin($);
    await dismissSnackbars($);
    await $(E2eKeys.navProfileTab).tap();
    await $.pumpAndSettle(timeout: const Duration(seconds: 20));

    await $(E2eKeys.profileLogoutButton).scrollTo().tap();
    await $.pumpAndSettle();

    // Logout vuelve al login.
    expect(isOnLogin($), isTrue);
  });
}
