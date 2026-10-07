import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:cart/src/presentation/widgets/quantity_stepper.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    final blocked = item.blocksCheckout;
    // Agrisado cuando la línea no puede confirmarse (sin stock suficiente o
    // producto eliminado del catálogo); Quitar y el stepper siguen activos
    // para que el usuario pueda resolverlo.
    return Opacity(
      opacity: blocked ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SwColors.surface,
                borderRadius: BorderRadius.circular(10),
                image: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(p.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.sku,
                    style: SwText.mono(size: 11, letterSpacing: 0.05),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.name,
                    style: SwText.body(
                      size: 14,
                      weight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (blocked) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: SwColors.stockOut.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.unavailable
                            ? 'Ya no disponible'
                            : 'Sin stock suficiente (quedan ${p.stock.available})',
                        style: SwText.body(
                          size: 11,
                          weight: FontWeight.w600,
                          color: SwColors.stockOut,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantityStepper(
                        quantity: item.quantity,
                        min: 1,
                        max: p.maxOrderableQuantity,
                        onChanged: onQuantityChanged,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.subtotal.formatted,
                            key: E2eKeys.cartItemSubtotal(p.id),
                            style: SwText.display(size: 16),
                          ),
                          GestureDetector(
                            onTap: onRemove,
                            child: Text(
                              'Quitar',
                              style: SwText.body(
                                size: 12,
                                color: SwColors.link,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
