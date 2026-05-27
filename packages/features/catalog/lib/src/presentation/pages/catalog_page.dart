import 'package:catalog/src/presentation/bloc/catalog_cubit.dart';
import 'package:catalog/src/presentation/widgets/product_card.dart';
import 'package:catalog/src/presentation/widgets/product_card_skeleton.dart';
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
        child: BlocBuilder<CatalogCubit, CatalogState>(
          bloc: widget.cubit,
          builder: (context, state) {
            return Column(
              children: [
                _CatalogAppBar(state: state),
                // Search bar oculto: el backend todavía no soporta `search` ni
                // `category` filtering. Cuando esté listo, restaurar:
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                //   child: CatalogSearchBar(
                //     controller: _searchController,
                //     onChanged: widget.cubit.setQuery,
                //     onSubmit: widget.cubit.submitSearch,
                //   ),
                // ),
                Expanded(child: _Results(cubit: widget.cubit, state: state, onProductTap: _onProductTap)),
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
      return const Center(child: CircularProgressIndicator());
    }
    if (s is CatalogError) {
      return _ErrorView(message: s.message, onRetry: cubit.load);
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
