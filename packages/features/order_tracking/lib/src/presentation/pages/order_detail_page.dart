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
    return BottomNavigationBarFeatureBuilder.buildScaffold(
      context,
      selectedTab: const NavigationBarOption.orders(),
      scrollable: false,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text('Order detail', style: SwText.body(size: 18, weight: FontWeight.w600)),
      ),
      child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          OrderDetailLoading() => const Center(child: SwLoadingSpinner()),
          OrderDetailError(:final message) => SwErrorView(
              message: message,
              onRetry: () => cubit.load(orderId),
            ),
          OrderDetailReady(:final order) => _DetailContent(order: order),
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ${order.id}',
                  style: SwText.body(size: 16, weight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                'Placed ${_formatDate(order.createdAt)}',
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrderStatusTimeline(status: order.status),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: SwColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Order details',
              style: SwText.body(size: 14, weight: FontWeight.w600)),
        ),
        if (order.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('No items', style: SwText.body(size: 14, color: SwColors.text3)),
          )
        else
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: SwText.body(size: 14)),
                        const SizedBox(height: 2),
                        Text(
                          '${item.productId} · qty ${item.quantity}',
                          style: SwText.body(size: 12, color: SwColors.text3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
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
