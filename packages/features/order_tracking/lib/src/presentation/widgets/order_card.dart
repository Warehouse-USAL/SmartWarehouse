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
      child: SwCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${order.id}',
                    style: SwText.body(size: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: SwText.body(size: 12, color: SwColors.text3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(status: order.status),
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
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Yesterday, $time';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: SwText.body(size: 12, color: _textColor, weight: FontWeight.w500),
      ),
    );
  }

  String get _label => switch (status) {
        OrderStatus.pending => 'Pending',
        OrderStatus.inProgress => 'In progress',
        OrderStatus.completed => 'Completed',
        OrderStatus.cancelled => 'Cancelled',
      };

  Color get _bgColor => switch (status) {
        OrderStatus.pending => SwColors.yellowSoft,
        OrderStatus.inProgress => const Color(0xFFEBF3FF),
        OrderStatus.completed => const Color(0xFFE6F4EA),
        OrderStatus.cancelled => SwColors.surface,
      };

  Color get _textColor => switch (status) {
        OrderStatus.pending => SwColors.yellowDark,
        OrderStatus.inProgress => SwColors.link,
        OrderStatus.completed => SwColors.stockIn,
        OrderStatus.cancelled => SwColors.text3,
      };
}
