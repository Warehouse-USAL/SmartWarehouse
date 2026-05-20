import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:catalog/src/presentation/widgets/catalog_search_bar.dart';
import 'package:catalog/src/presentation/widgets/category_filter_bar.dart';
import 'package:catalog/src/presentation/widgets/product_card.dart';
import 'package:catalog/src/presentation/widgets/product_card_skeleton.dart';
import 'package:catalog/src/presentation/widgets/sw_icon_button.dart';
import 'package:catalog/src/presentation/widgets/sw_logo_mark.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({required this.cubit, super.key});
  final CatalogCubit cubit;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    if (widget.cubit.state is! CatalogReady) {
      widget.cubit.load();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar:
          BottomNavigationBarFeatureBuilder.build(context, const NavigationBarOption.products()),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CatalogAppBar(cubit: widget.cubit),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                bloc: widget.cubit,
                builder: (context, state) {
                  return switch (state) {
                    CatalogLoading() => const Center(child: CircularProgressIndicator()),
                    CatalogError(:final message) =>
                        _ErrorView(message: message, onRetry: widget.cubit.load),
                    CatalogReady() => _ReadyView(
                        cubit: widget.cubit,
                        state: state,
                        searchController: _searchController,
                        onProductTap: (id) => _onProductTap(context, id),
                      ),
                  };
                },
              ),
            ),
          ],
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
  const _CatalogAppBar({required this.cubit});
  final CatalogCubit cubit;

  @override
  Widget build(BuildContext context) {
    final state = cubit.state;
    final count = state is CatalogReady ? state.total : 0;
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
                    '$count items',
                    style: SwText.body(size: 13, color: SwColors.text3),
                  ),
                ),
              ],
            ),
          ),
          SwIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () {},
            badge: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: SwColors.yellowDark,
                shape: BoxShape.circle,
                border: Border.all(color: SwColors.surface, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
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

class _ReadyView extends StatelessWidget {
  const _ReadyView({
    required this.cubit,
    required this.state,
    required this.searchController,
    required this.onProductTap,
  });

  final CatalogCubit cubit;
  final CatalogReady state;
  final TextEditingController searchController;
  final void Function(String productId) onProductTap;

  static const _footerSlotCount = 2;

  @override
  Widget build(BuildContext context) {
    final products = state.products;
    final showSkeletons = state.isLoadingMore;
    final showErrorFooter = state.loadMoreError != null && !state.isLoadingMore;
    final footerSlots = (showSkeletons || showErrorFooter) ? _footerSlotCount : 0;
    final itemCount = products.length + footerSlots;

    final resultText = state.hasNext
        ? '${products.length} de ${state.total}'
        : '${state.total} resultado${state.total == 1 ? '' : 's'}';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: CatalogSearchBar(controller: searchController, onChanged: cubit.setQuery),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: CategoryFilterBar(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            onSelected: cubit.selectCategory,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resultText,
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty && !state.isLoadingMore
              ? const _EmptyView()
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
                        onTap: () => onProductTap(product.id),
                      );
                    }
                    if (showSkeletons) {
                      return const ProductCardSkeleton();
                    }
                    return _LoadMoreErrorCard(
                      message: state.loadMoreError!,
                      onRetry: cubit.retryLoadMore,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LoadMoreErrorCard extends StatelessWidget {
  const _LoadMoreErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: SwColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: SwColors.stockOut, size: 28),
              const SizedBox(height: 8),
              Text(
                message,
                style: SwText.body(size: 12, color: SwColors.text3),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Tocá para reintentar',
                style: SwText.body(size: 11, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          'No se encontraron productos.',
          style: SwText.body(size: 14, color: SwColors.text3),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: SwColors.stockOut, size: 40),
          const SizedBox(height: 12),
          Text(message, style: SwText.body(size: 14)),
          const SizedBox(height: 16),
          SwButton(
            label: 'Reintentar',
            variant: SwButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
