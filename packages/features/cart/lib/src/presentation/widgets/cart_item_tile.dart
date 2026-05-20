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
    return Padding(
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
                  ? DecorationImage(image: NetworkImage(p.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.sku, style: SwText.mono(size: 11, letterSpacing: 0.05)),
                const SizedBox(height: 2),
                Text(
                  p.name,
                  style: SwText.body(size: 14, weight: FontWeight.w600, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Zona ${p.location!.idZone} · L${p.location!.idLine} · P${p.location!.idPosition}',
                    style: SwText.body(size: 11, color: SwColors.text3),
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
                          style: SwText.display(size: 16),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: Text('Remove',
                              style: SwText.body(size: 12, color: SwColors.link)),
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
    );
  }
}
