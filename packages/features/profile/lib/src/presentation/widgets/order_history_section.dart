import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/presentation/widgets/order_history_item.dart';

class OrderHistorySection extends StatelessWidget {
  const OrderHistorySection({required this.orders, super.key});

  final List<OrderSummary> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial de pedidos', style: SwText.display(size: 18)),
        const SizedBox(height: 12),
        SwCard(
          child: Column(
            children: [
              for (int i = 0; i < orders.length; i++) ...[
                OrderHistoryItem(order: orders[i]),
                if (i < orders.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: SwColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
