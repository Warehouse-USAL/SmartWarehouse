import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/api_helpers.dart';
import 'common/patrol_helpers.dart';

/// E8.3.9 — checkout con monedas mezcladas bloqueado: con dos productos de
/// monedas distintas en el carrito, el total no es representable y confirmar
/// muestra el aviso en vez de crear la orden (hardening de E4.21).
///
/// El seed local es todo ARS, así que el setup cambia temporalmente la moneda
/// del segundo producto del listado a USD vía PATCH /products/{id} y el
/// teardown la restaura SIEMPRE (contrato de datos: docs/e2e-data-contract.md).
void main() {
  patrolTest('el checkout con monedas mezcladas se bloquea con aviso', ($) async {
    final token = await E2eApi.adminToken();
    final products = await E2eApi.firstProducts(token, count: 2);
    expect(products, hasLength(2), reason: 'El seed necesita >= 2 productos');
    final a = products[0];
    final b = products[1];
    final bPrice = b['price'] as Map<String, dynamic>;
    final bCents = bPrice['amount_cents'] as int;
    final bCurrency = bPrice['currency'] as String;

    await E2eApi.patchProductCurrency(
      token,
      b['id'] as String,
      amountCents: bCents,
      currency: bCurrency == 'USD' ? 'ARS' : 'USD',
    );

    try {
      await bootAndLogin($);

      // Agregar el producto A y volver al catálogo.
      await $(E2eKeys.productCard(a['id'] as String)).tap();
      await $(E2eKeys.productDetailAddToCart).waitUntilVisible();
      await $(E2eKeys.productDetailAddToCart).tap();
      await $.pumpAndSettle();
      await dismissSnackbars($);
      await $(E2eKeys.navCatalogTab).tap();
      await $.pumpAndSettle();

      // Agregar el producto B (moneda distinta).
      await $(E2eKeys.productCard(b['id'] as String)).scrollTo().tap();
      await $(E2eKeys.productDetailAddToCart).waitUntilVisible();
      await $(E2eKeys.productDetailAddToCart).tap();
      await $.pumpAndSettle();
      await dismissSnackbars($);

      // En el carrito, confirmar tiene que mostrar el aviso y NO abrir el
      // diálogo de confirmación (no se crea ninguna orden).
      await $(E2eKeys.navCartTab).tap();
      await $.pumpAndSettle();
      await $(E2eKeys.cartCheckoutButton).scrollTo().tap();
      await $('Hay productos con monedas distintas en el pedido. '
              'Quitá los que no correspondan para continuar.')
          .waitUntilVisible();
      expect(
        $.tester.any(find.byKey(E2eKeys.orderConfirmDialogTotal)),
        isFalse,
        reason: 'El diálogo de confirmación no debe abrirse con monedas mezcladas',
      );
    } finally {
      await E2eApi.patchProductCurrency(
        token,
        b['id'] as String,
        amountCents: bCents,
        currency: bCurrency,
      );
    }
  });
}
