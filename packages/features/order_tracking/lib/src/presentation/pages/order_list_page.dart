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
        automaticallyImplyLeading: false,
        title: Text('Órdenes', style: SwText.display(size: 26)),
      ),
      child: BlocBuilder<OrderListCubit, OrderListState>(
        bloc: cubit,
        builder: (context, state) => switch (state) {
          OrderListLoading() => const Center(child: SwLoadingSpinner()),
          OrderListError(:final message) => SwErrorView(
              message: message,
              onRetry: cubit.refresh,
            ),
          OrderListReady(:final orders) => RefreshIndicator(
              color: SwColors.yellow,
              onRefresh: cubit.refresh,
              child: orders.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: SwEmptyView(
                          title: 'Sin órdenes',
                          message:
                              'Tus pedidos aparecerán aquí una vez que realices uno.',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        SwCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < orders.length; i++) ...[
                                OrderCard(
                                  order: orders[i],
                                  onTap: () => Injector.i
                                      .resolve<NavigationHelper>()
                                      .pushNamed(
                                        context,
                                        routeName:
                                            Routes.orderDetail(orders[i].id),
                                      ),
                                ),
                                if (i < orders.length - 1)
                                  const Divider(height: 1, color: SwColors.border),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
        },
      ),
    );
  }
}
