import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, required this.onTap, super.key});

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SwColors.yellowSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: SwColors.yellowDark,
              ),
            ),
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
                    '${_formatDate(order.createdAt)} · ${order.items.length} items · ${_statusLabel(order.status)}',
                    style: SwText.body(size: 12, color: SwColors.text3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.total.formatted,
                  style: SwText.body(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const Icon(Icons.chevron_right, size: 16, color: SwColors.text3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(dtDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'Pending',
        OrderStatus.inProgress => 'In progress',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };
}
