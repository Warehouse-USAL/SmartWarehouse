import 'package:catalog/catalog.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';

void main() {
  patrolTest('catálogo lista productos con precios bien formateados', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);
    final cardPrice = textOf($, E2eKeys.productCardPrice(productId));
    // Todo precio visible debe respetar el formato único de Money.formatted.
    parsePriceToCents(cardPrice);
  });

  patrolTest('la búsqueda filtra por SKU', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);
    final card = $.tester.widget<ProductCard>(
      find.byKey(E2eKeys.productCard(productId)),
    );
    final sku = card.product.sku;

    await $(E2eKeys.catalogSearchField).enterText(sku);
    await $('Buscar').tap();
    await $.pumpAndSettle(timeout: const Duration(seconds: 15));

    expect(find.text(sku), findsWidgets);
  });

  patrolTest('el detalle muestra el mismo precio que la card del catálogo', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);
    final cardPrice = textOf($, E2eKeys.productCardPrice(productId));

    await $(E2eKeys.productCard(productId)).tap();
    await $(E2eKeys.productDetailPrice).waitUntilVisible();
    final detailPrice = textOf($, E2eKeys.productDetailPrice);

    // Guardia de regresión: /products usa `amount` y /products/{id} usa
    // `amount_cents`; si el mapeo diverge, esto lo atrapa.
    expect(
      parsePriceToCents(detailPrice),
      parsePriceToCents(cardPrice),
      reason: 'El precio del detalle ($detailPrice) difiere de la card ($cardPrice)',
    );
    expect(detailPrice, cardPrice);
  });
}
