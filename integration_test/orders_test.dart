import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';

void main() {
  patrolTest('la lista de órdenes carga y abre el detalle', ($) async {
    await bootAndLogin($);
    await dismissSnackbars($);
    await $(E2eKeys.navOrdersTab).tap();
    await $.pumpAndSettle(timeout: const Duration(seconds: 20));

    await $('Órdenes').waitUntilVisible();

    // Cards de orden keyeadas como e2e_order_card_<id>.
    final cards = find.byWidgetPredicate((w) {
      final key = w.key;
      return key is ValueKey<String> && key.value.startsWith('e2e_order_card_');
    });

    if (cards.evaluate().isEmpty) {
      // Backend sin órdenes: el empty state debe renderizar sin error.
      await $('Sin órdenes').waitUntilVisible();
      return;
    }

    await $.tester.tap(cards.first);
    await $.pumpAndSettle(timeout: const Duration(seconds: 20));
    await $('Detalles del pedido').waitUntilVisible();
  });
}
