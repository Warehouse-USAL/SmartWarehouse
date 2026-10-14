import 'package:cart/src/domain/entities/cart.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Confirmación previa a crear la orden. Es un [SwDialog] de marca; este
/// wrapper arma el copy y la fila de total, y conserva las keys de e2e.
class CreateOrderConfirmationDialog {
  const CreateOrderConfirmationDialog._();

  static Future<bool> show(BuildContext context, Cart cart) {
    final total = cart.total;
    final units =
        '${cart.itemCount} ${cart.itemCount == 1 ? 'unidad' : 'unidades'}';
    return SwDialog.show(
      context,
      title: 'Confirmar orden',
      message:
          '${cart.items.length} '
          '${cart.items.length == 1 ? 'producto' : 'productos'} · $units. '
          'Vas a crear la orden con los productos de tu pedido.',
      body: total == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: SwColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Total',
                      style: SwText.body(size: 13, color: SwColors.text2),
                    ),
                    Text(
                      total.formatted,
                      key: E2eKeys.orderConfirmDialogTotal,
                      style: SwText.display(size: 22),
                    ),
                  ],
                ),
              ),
            ),
      confirmLabel: 'Confirmar',
      cancelLabel: 'Cancelar',
      confirmKey: E2eKeys.orderConfirmAccept,
      cancelKey: E2eKeys.orderConfirmCancel,
    );
  }
}
