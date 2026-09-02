import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/api_helpers.dart';
import 'common/patrol_helpers.dart';

void main() {
  patrolTest('agregar al carrito mantiene precio y moneda consistentes', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);
    final cardPrice = textOf($, E2eKeys.productCardPrice(productId));
    final cardCents = parsePriceToCents(cardPrice);

    // Detalle: precio unitario y total del botón (qty 1) deben coincidir.
    await $(E2eKeys.productCard(productId)).tap();
    await $(E2eKeys.productDetailPrice).waitUntilVisible();
    final detailCents = parsePriceToCents(textOf($, E2eKeys.productDetailPrice));
    expect(detailCents, cardCents,
        reason: 'Precio detalle difiere del catálogo para $productId');

    // Subimos qty a 2: el total del botón debe ser exactamente unit × 2.
    await $(E2eKeys.productDetailQtyIncrement).tap();
    await $.pump();
    final addLabel = $.tester
        .widget<SwButton>(find.byKey(E2eKeys.productDetailAddToCart))
        .label;
    final buttonCents = parsePriceToCents(extractEmbeddedPrice(addLabel));
    expect(buttonCents, detailCents * 2,
        reason: 'Total del botón agregar no es unit × qty');

    await $(E2eKeys.productDetailAddToCart).tap();
    await $.pumpAndSettle();

    // Carrito: subtotal de la línea = unit × 2, total = suma de subtotales.
    await dismissSnackbars($);
    await $(E2eKeys.navCartTab).tap();
    await $.pumpAndSettle();

    await $(E2eKeys.cartItemSubtotal(productId)).waitUntilVisible();
    final lineCents =
        parsePriceToCents(textOf($, E2eKeys.cartItemSubtotal(productId)));
    expect(lineCents, detailCents * 2,
        reason: 'Subtotal en carrito difiere del precio del catálogo/detalle — '
            'posible bug de moneda entre endpoints');

    final totalCents = parsePriceToCents(textOf($, E2eKeys.cartTotal));
    expect(totalCents, lineCents, reason: 'Total del carrito no suma las líneas');
  });

  patrolTest('checkout completo crea la orden con el total correcto', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);

    await $(E2eKeys.productCard(productId)).tap();
    await $(E2eKeys.productDetailAddToCart).waitUntilVisible();
    await $(E2eKeys.productDetailAddToCart).tap();
    await $.pumpAndSettle();

    await dismissSnackbars($);
    await $(E2eKeys.navCartTab).tap();
    await $.pumpAndSettle();

    final totalCents = parsePriceToCents(textOf($, E2eKeys.cartTotal));

    await $(E2eKeys.cartCheckoutButton).tap();
    await $(E2eKeys.orderConfirmDialogTotal).waitUntilVisible();

    // El total del diálogo de confirmación debe ser el mismo del carrito.
    final dialogPrice =
        extractEmbeddedPrice(textOf($, E2eKeys.orderConfirmDialogTotal));
    expect(parsePriceToCents(dialogPrice), totalCents,
        reason: 'Total del diálogo difiere del total del carrito');

    await $(E2eKeys.orderConfirmAccept).tap();
    await $.pumpAndSettle();

    // Sheet de dirección de entrega: los campos requeridos DEBEN estar (si el
    // sheet cambia, el test falla acá en vez de "pasar" por otro camino).
    await $(E2eKeys.checkoutAddressStreet).waitUntilVisible();
    final street = $.tester
        .widget<TextFormField>(find.byKey(E2eKeys.checkoutAddressStreet));
    if ((street.controller?.text ?? '').isEmpty) {
      await $(E2eKeys.checkoutAddressStreet).enterText('Av. Siempreviva 742');
    }
    final zip = $.tester
        .widget<TextFormField>(find.byKey(E2eKeys.checkoutAddressPostalCode));
    if ((zip.controller?.text ?? '').isEmpty) {
      await $(E2eKeys.checkoutAddressPostalCode).enterText('1414');
    }
    await $.pump();
    await $(E2eKeys.checkoutAddressSubmit).tap();
    await $.pumpAndSettle(timeout: const Duration(seconds: 30));

    // Pantalla de éxito.
    await $('¡Pedido creado!').waitUntilVisible();

    // Teardown: cancelar las órdenes pending para no ensuciar corridas
    // futuras (contrato de datos: docs/e2e-data-contract.md).
    await E2eApi.cancelPendingOrders(await E2eApi.adminToken());
  });

  patrolTest('quitar el único item deja el carrito vacío', ($) async {
    await bootAndLogin($);
    final productId = firstVisibleProductId($);

    await $(E2eKeys.productCard(productId)).tap();
    await $(E2eKeys.productDetailAddToCart).waitUntilVisible();
    await $(E2eKeys.productDetailAddToCart).tap();
    await $.pumpAndSettle();

    await dismissSnackbars($);
    await $(E2eKeys.navCartTab).tap();
    await $.pumpAndSettle();

    await $(E2eKeys.cartItemSubtotal(productId)).waitUntilVisible();
    await $('Quitar').tap();
    await $.pumpAndSettle();

    await $('Tu pedido está vacío').waitUntilVisible();
  });
}
