import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:catalog/catalog.dart';
import 'package:catalog/src/presentation/bloc/product_detail_cubit.dart';
import 'package:catalog/src/presentation/widgets/qty_stepper.dart';
import 'package:catalog/src/presentation/widgets/stock_badge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.cubit,
    required this.onAddToCart,
    super.key,
  });

  final ProductDetailCubit cubit;
  final void Function(Product product) onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar: BottomNavigationBarFeatureBuilder.build(
          context, const NavigationBarOption.products()),
      body: SafeArea(
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          bloc: cubit,
          builder: (context, state) {
            return switch (state) {
              ProductDetailLoading() =>
                const Center(child: CircularProgressIndicator()),
              ProductDetailError(:final message) =>
                Center(child: Text(message, style: SwText.body())),
              ProductDetailReady() => _DetailView(
                  state: state,
                  cubit: cubit,
                  onAddToCart: onAddToCart,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.state,
    required this.cubit,
    required this.onAddToCart,
  });

  final ProductDetailReady state;
  final ProductDetailCubit cubit;
  final void Function(Product product) onAddToCart;

  static const _tabs = ['Descripción', 'Especificaciones'];

  List<ProductImage> _gallery(Product p) {
    final imgs = p.images;
    if (imgs != null && imgs.isNotEmpty) return imgs;
    final fallback = p.imageUrl;
    if (fallback != null && fallback.isNotEmpty) {
      return [ProductImage(url: fallback, isPrimary: true)];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final p = state.product;
    final outOfStock = p.stock.isOutOfStock;
    final maxQty = p.maxOrderableQuantity;
    final gallery = _gallery(p);
    return Column(
      children: [
        _AppBar(sku: p.sku, onBack: () => Navigator.of(context).maybePop()),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _ImageCarousel(
                  gallery: gallery,
                  activeIndex: state.activeImage,
                  controller: cubit.pageController,
                  onPageChanged: cubit.onPageChanged,
                  onThumbnailTap: cubit.jumpToImage,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.category.name.toUpperCase(),
                        style: SwText.mono(size: 12, color: SwColors.text3, letterSpacing: 0.08),
                      ),
                      const SizedBox(height: 6),
                      Text(p.name, style: SwText.display(size: 22, height: 1.2)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(p.price.formatted, style: SwText.display(size: 30)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: StockBadge(stock: p.stock),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Tabs(active: state.activeTab, onChanged: cubit.setActiveTab),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: switch (state.activeTab) {
                    0 => Text(
                      p.description ?? 'Sin descripción disponible. Producto del catálogo SmartWarehouse.',
                      style: SwText.body(size: 14, color: SwColors.text2, height: 1.55),
                    ),
                    _ => _Specs(product: p),
                  },
                ),
              ],
            ),
          ),
        ),
        _StickyFooter(
          qty: state.qty,
          maxQty: maxQty,
          unitPrice: p.price,
          disabled: outOfStock,
          onQtyChanged: cubit.setQty,
          onAdd: () {
            for (var i = 0; i < state.qty; i++) {
              onAddToCart(p);
            }
          },
        ),
      ],
    );
  }
}

/// Carrusel swipeable de imágenes del producto + dots indicator.
///
/// - Si la galería trae 1 imagen → se renderiza fija.
/// - Si trae 2+ → `PageView` horizontal con dots animados abajo.
/// - Si está vacía → placeholder rayado del design system.
class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.gallery,
    required this.activeIndex,
    required this.controller,
    required this.onPageChanged,
    required this.onThumbnailTap,
  });

  final List<ProductImage> gallery;
  final int activeIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    if (gallery.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const AspectRatio(
          aspectRatio: 1,
          child: SwImgPlaceholder(borderRadius: 18, tinted: true),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: PageView.builder(
                controller: controller,
                onPageChanged: onPageChanged,
                itemCount: gallery.length,
                itemBuilder: (context, i) {
                  final img = gallery[i];
                  return SwImgPlaceholder(
                    label: img.alt,
                    tinted: i == 0,
                    imageUrl: img.url,
                    borderRadius: 18,
                  );
                },
              ),
            ),
          ),
        ),
        if (gallery.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: gallery.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == activeIndex;
                return _Thumbnail(
                  image: gallery[i],
                  selected: selected,
                  tinted: i == 0,
                  onTap: () => onThumbnailTap(i),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.image,
    required this.selected,
    required this.tinted,
    required this.onTap,
  });

  final ProductImage image;
  final bool selected;
  final bool tinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? SwColors.text : SwColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SwImgPlaceholder(
            borderRadius: 8,
            tinted: tinted,
            imageUrl: image.url,
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.sku, required this.onBack});

  final String sku;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          SwIconButton(icon: Icons.chevron_left, onPressed: onBack),
          Expanded(
            child: Center(
              child: Text(sku, style: SwText.mono(size: 13, color: SwColors.text3, letterSpacing: 0.05)),
            ),
          ),
          // Espaciador para mantener el SKU centrado (mismo ancho que el botón back).
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.onChanged});

  final int active;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SwColors.border)),
      ),
      child: Row(
        children: List.generate(_DetailView._tabs.length, (i) {
          final isActive = i == active;
          return Padding(
            padding: EdgeInsets.only(right: i < _DetailView._tabs.length - 1 ? 24 : 0),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isActive ? SwColors.yellow : Colors.transparent, width: 2)),
                ),
                child: Text(
                  _DetailView._tabs[i],
                  style: SwText.body(
                    size: 14,
                    weight: FontWeight.w600,
                    color: isActive ? SwColors.text : SwColors.text3,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Specs extends StatelessWidget {
  const _Specs({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('SKU', product.sku),
      ('Categoría', product.category.name),
      ('Stock disponible', '${product.stock.available}'),
      ('Máx. por orden', '${product.orderConstraints.maxQuantityPerOrder}'),
      ('Precio unitario', product.price.formatted),
      if (product.specs != null)
        for (final s in product.specs!) (s.label, s.value),
    ];
    return SwCard(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          for (final (i, e) in entries.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < entries.length - 1 ? const Border(bottom: BorderSide(color: SwColors.border)) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.$1, style: SwText.body(size: 14, color: SwColors.text3)),
                  ),
                  Text(e.$2, style: SwText.body(size: 14, weight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StickyFooter extends StatelessWidget {
  const _StickyFooter({
    required this.qty,
    required this.maxQty,
    required this.unitPrice,
    required this.disabled,
    required this.onQtyChanged,
    required this.onAdd,
  });

  final int qty;
  final int maxQty;
  final Money unitPrice;
  final bool disabled;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final total = unitPrice * qty;
    final label = 'Agregar al pedido · ${total.formatted}';
    return Container(
      decoration: const BoxDecoration(
        color: SwColors.white,
        border: Border(top: BorderSide(color: SwColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QtyStepper(value: qty, onChanged: onQtyChanged, min: 1, max: maxQty, large: true),
            const SizedBox(width: 12),
            Expanded(
              child: SwButton(label: label, icon: Icons.add, onPressed: disabled ? null : onAdd),
            ),
          ],
        ),
      ),
    );
  }
}
