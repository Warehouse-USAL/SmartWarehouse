import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/api_helpers.dart';
import 'common/patrol_helpers.dart';

/// E8.3.9 — paginación / scroll infinito del catálogo: con más de una página
/// de productos, scrollear hasta el final tiene que disparar el load de la
/// página 2 y agregar sus productos al listado.
///
/// El seed local tiene 16 productos y la página es de 20, así que el setup
/// crea productos temporales (SKU E2E-PAG-*) hasta superar una página y el
/// teardown los borra (contrato de datos: docs/e2e-data-contract.md).
void main() {
  patrolTest('scrollear el catálogo carga la página 2', ($) async {
    final token = await E2eApi.adminToken();
    const pageSize = 20;
    final created = <String>[];
    // Crear lo suficiente para garantizar 2 páginas. SKU único por corrida:
    // el DELETE del teardown es soft y deja el SKU reservado para siempre
    // (un inactivo no se puede reactivar por PATCH), así que reutilizar SKUs
    // fijos rompería la segunda corrida.
    final runId = DateTime.now().millisecondsSinceEpoch;
    for (var i = 1; i <= 6; i++) {
      created.add(await E2eApi.createProduct(
        token,
        sku: 'E2E-PAG-$runId-$i',
        name: 'E2E paginación $i',
      ));
    }

    try {
      final page2 = await E2eApi.productOnPage(token, 2, size: pageSize);
      expect(
        page2,
        isNotNull,
        reason: 'El backend no devuelve página 2: el setup no alcanzó '
            'para superar una página de $pageSize.',
      );
      final page2Id = page2!['id'] as String;

      await bootAndLogin($);
      // Scroll infinito: flings hasta que la card de la página 2 se monte.
      // Cada iteración deja settlear para que el loadMore dispare y renderice.
      final page2Card = find.byKey(E2eKeys.productCard(page2Id));
      for (var i = 0; i < 30 && page2Card.evaluate().isEmpty; i++) {
        // Ojo: el primer Scrollable de la página es la barra horizontal de
        // categorías; hay que scrollear la grilla de productos.
        await $.tester.fling(
          find.byType(GridView),
          const Offset(0, -600),
          2000,
        );
        await $.pumpAndSettle();
      }
      await $(E2eKeys.productCard(page2Id)).waitUntilVisible();
    } finally {
      for (final id in created) {
        try {
          await E2eApi.deleteProduct(token, id);
        } catch (_) {
          // Best effort: no enmascarar la falla real del test.
        }
      }
    }
  });
}
