import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/presentation/widgets/order_card.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({required this.cubit, super.key});

  final OrderListCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBarFeatureBuilder.buildScaffold(
      context,
      selectedTab: const NavigationBarOption.orders(),
      scrollable: false,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text('My orders', style: SwText.body(size: 18, weight: FontWeight.w600)),
        automaticallyImplyLeading: false,
      ),
      child: BlocBuilder<OrderListCubit, OrderListState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          OrderListLoading() => const Center(child: SwLoadingSpinner()),
          OrderListError(:final message) => SwErrorView(
              message: message,
              onRetry: cubit.refresh,
            ),
          OrderListReady(:final orders) => orders.isEmpty
              ? const SwEmptyView(
                  title: 'No orders yet',
                  message: 'Your orders will appear here once you place one.',
                  icon: Icons.receipt_long_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => OrderCard(
                    order: orders[i],
                    onTap: () => Injector.i.resolve<NavigationHelper>().pushNamed(
                          context,
                          routeName: Routes.orderDetail(orders[i].id),
                        ),
                  ),
                ),
        },
      ),
    );
  }
}
