import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:catalog/src/presentation/widgets/product_card.dart';
import 'package:catalog/src/presentation/widgets/product_card_skeleton.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/catalog_search_bar.dart';
import '../widgets/category_filter_bar.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    // Kick-off del primer fetch si el cubit aún no cargó.
    if (cubit.state is! CatalogReady) {
      // Microtask para no llamar emit durante build.
      Future.microtask(cubit.load);
    }
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar:
          BottomNavigationBarFeatureBuilder.build(context, const NavigationBarOption.products()),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CatalogCubit, CatalogState>(
          bloc: cubit,
          builder: (context, state) {
            return Column(
              children: [
                _CatalogAppBar(state: state),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: CatalogSearchBar(
                    controller: cubit.searchController,
                    onChanged: cubit.setQuery,
                    onSubmit: cubit.submitSearch,
                  ),
                ),
                if (cubit.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: CategoryFilterBar(
                      categories: cubit.categories,
                      selectedCategory: cubit.selectedCategory,
                      onSelected: cubit.selectCategory,
                    ),
                  ),
                Expanded(child: _Results(cubit: cubit, state: state, onProductTap: _onProductTap)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onProductTap(BuildContext context, String productId) {
    Injector.i.resolve<NavigationHelper>().pushNamed(
          context,
          routeName: Routes.catalogDetail(productId),
        );
  }
}

class _CatalogAppBar extends StatelessWidget {
  const _CatalogAppBar({required this.state});
  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final count = state is CatalogReady ? (state as CatalogReady).total : null;
    final subtitle = count == null ? 'Cargando…' : '$count items';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SwLogoMark(size: 36),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Catálogo',
                        style: SwText.display(size: 26),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 46),
                  child: Text(
                    subtitle,
                    style: SwText.body(size: 13, color: SwColors.text3),
                  ),
                ),
              ],
            ),
          ),

          SwIconButton(
            icon: Icons.logout,
            tooltip: 'Cerrar sesión',
            onPressed: () => AuthFeatureBuilder.logout(),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.cubit,
    required this.state,
    required this.onProductTap,
  });

  final CatalogCubit cubit;
  final CatalogState state;
  final void Function(BuildContext context, String productId) onProductTap;

  static const _footerSlotCount = 2;

  @override
  Widget build(BuildContext context) {
    final s = state;
    if (s is CatalogLoading) {
      return const SwLoadingSpinner();
    }
    if (s is CatalogError) {
      return SwErrorView(message: s.message, onRetry: cubit.load);
    }
    final ready = s as CatalogReady;
    final products = ready.products;
    final showSkeletons = ready.isLoadingMore;
    final showErrorFooter = ready.loadMoreError != null && !ready.isLoadingMore;
    final footerSlots = (showSkeletons || showErrorFooter) ? _footerSlotCount : 0;
    final itemCount = products.length + footerSlots;

    final resultText = ready.hasNext
        ? '${products.length} de ${ready.total}'
        : '${ready.total} resultado${ready.total == 1 ? '' : 's'}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Row(
            children: [
              Text(resultText, style: SwText.body(size: 12, color: SwColors.text3)),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty && !ready.isLoadingMore
              ? const SwEmptyView(
                  title: 'No se encontraron productos',
                  message: 'Probá ajustando los filtros o buscando otro término.',
                )
              : GridView.builder(
                  controller: cubit.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      final product = products[index];
                      final tinted = index % 5 == 0;
                      return ProductCard(
                        product: product,
                        tinted: tinted,
                        onTap: () => onProductTap(context, product.id),
                      );
                    }
                    if (showErrorFooter) {
                      return Center(
                        child: TextButton(
                          onPressed: cubit.retryLoadMore,
                          child: Text('Reintentar',
                              style: SwText.body(size: 13, color: SwColors.link, weight: FontWeight.w700)),
                        ),
                      );
                    }
                    return const ProductCardSkeleton();
                  },
                ),
        ),
      ],
    );
  }
}
