import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/order_summary.dart';

class OrderHistoryItem extends StatelessWidget {
  const OrderHistoryItem({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _OrderIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: SwText.body(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.dateLabel} · ${order.itemsLabel} · ${order.statusLabel}',
                  style: SwText.body(size: 12, color: SwColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.formattedTotal,
            style: SwText.body(size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: SwColors.text3,
          ),
        ],
      ),
    );
  }
}

class _OrderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: SwColors.yellowSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 18,
        color: SwColors.yellowDark,
      ),
    );
  }
}
