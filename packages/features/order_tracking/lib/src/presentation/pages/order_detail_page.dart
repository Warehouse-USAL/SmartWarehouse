import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_timeline.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({required this.cubit, required this.orderId, super.key});

  final OrderDetailCubit cubit;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailCubit, OrderDetailState>(
      bloc: cubit,
      builder: (context, state) {
        final placedDate =
            state is OrderDetailReady ? _formatDate(state.order.createdAt) : null;

        return BottomNavigationBarFeatureBuilder.buildScaffold(
          context,
          selectedTab: const NavigationBarOption.orders(),
          scrollable: false,
          appBar: AppBar(
            backgroundColor: SwColors.white,
            elevation: 0,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order $orderId', style: SwText.display(size: 18)),
                if (placedDate != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Placed $placedDate',
                    style: SwText.body(size: 11, color: SwColors.text3),
                  ),
                ],
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SwColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 20,
                    color: SwColors.text,
                  ),
                ),
              ),
            ],
          ),
          child: switch (state) {
            OrderDetailLoading() => const Center(child: SwLoadingSpinner()),
            OrderDetailError(:final message) => SwErrorView(
                message: message,
                onRetry: () => cubit.load(orderId),
              ),
            OrderDetailReady(:final order) => _DetailContent(order: order),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Text('Status', style: SwText.display(size: 18)),
        ),
        SwCard(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
          child: OrderStatusTimeline(status: order.status),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text('Order details', style: SwText.display(size: 18)),
        ),
        SwCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: order.items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No items',
                    style: SwText.body(size: 14, color: SwColors.text3),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < order.items.length; i++) ...[
                      _ItemRow(item: order.items[i]),
                      if (i < order.items.length - 1)
                        const Divider(height: 1, color: SwColors.border),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SwColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SwColors.border),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: SwColors.text3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: SwText.body(size: 14, weight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.productId} · qty ${item.quantity}',
                  style: SwText.body(size: 12, color: SwColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            (item.unitPrice * item.quantity).formatted,
            style: SwText.body(size: 14, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
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
