import 'package:catalog/catalog.dart';
import 'package:catalog/src/domain/repositories/catalog_repository.dart';
import 'package:catalog/src/presentation/widgets/qty_stepper.dart';
import 'package:catalog/src/presentation/widgets/stock_badge.dart';
import 'package:catalog/src/presentation/widgets/sw_icon_button.dart';
import 'package:catalog/src/presentation/widgets/sw_img_placeholder.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    required this.productId,
    required this.repository,
    required this.onAddToCart,
    super.key,
  });

  final String productId;
  final CatalogRepository repository;
  final void Function(Product product) onAddToCart;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<({Product? product, String? error})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({Product? product, String? error})> _load() async {
    final result = await widget.repository.getProductById(widget.productId);
    return result.fold(
      (failure) => (product: null, error: failure.message ?? 'Error'),
      (product) => (product: product, error: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      body: FutureBuilder<({Product? product, String? error})>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.product == null) {
            return Center(
              child: Text(data.error ?? 'Producto no encontrado', style: SwText.body()),
            );
          }
          return _DetailView(
            product: data.product!,
            onAddToCart: widget.onAddToCart,
          );
        },
      ),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({required this.product, required this.onAddToCart});
  final Product product;
  final void Function(Product product) onAddToCart;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  int _qty = 1;
  int _activeTab = 0;
  int _activeImage = 0;
  static const _tabs = ['Description', 'Specs'];

  List<ProductImage> get _gallery {
    final imgs = widget.product.images;
    if (imgs != null && imgs.isNotEmpty) return imgs;
    final fallback = widget.product.imageUrl;
    if (fallback != null && fallback.isNotEmpty) {
      return [ProductImage(url: fallback, isPrimary: true)];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final outOfStock = p.stock.isOutOfStock;
    final maxQty = p.maxOrderableQuantity;
    final gallery = _gallery;
    final activeImage =
        gallery.isEmpty ? null : gallery[_activeImage.clamp(0, gallery.length - 1)];
    return SafeArea(
      child: Column(
        children: [
          _AppBar(sku: p.sku, onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: SwImgPlaceholder(
                        label: activeImage?.alt ??
                            'PRODUCT ${_activeImage + 1}${gallery.isEmpty ? '' : ' / ${gallery.length}'}',
                        tinted: _activeImage == 0,
                        imageUrl: activeImage?.url,
                        borderRadius: 18,
                      ),
                    ),
                  ),
                  if (gallery.length > 1) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(gallery.length, (i) {
                          final selected = i == _activeImage;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeImage = i),
                              child: Container(
                                margin: EdgeInsets.only(right: i < gallery.length - 1 ? 8 : 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selected ? SwColors.text : SwColors.border,
                                    width: selected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: SwImgPlaceholder(
                                    borderRadius: 8,
                                    tinted: i == 0,
                                    imageUrl: gallery[i].url,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
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
                        const SizedBox(height: 4),
                        Text(
                          p.price.taxIncluded == true
                              ? 'per unit · IVA incluido'
                              : 'per unit · ex. IVA',
                          style: SwText.body(size: 12, color: SwColors.text3),
                        ),
                      ],
                    ),
                  ),
                  if (p.shipping != null) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ShipsContextBlock(shipping: p.shipping!),
                    ),
                  ],
                  if (p.location != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _LocationBlock(location: p.location!),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _Tabs(active: _activeTab, onChanged: (i) => setState(() => _activeTab = i)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: switch (_activeTab) {
                      0 => Text(
                          p.description ??
                              'Sin descripción disponible. Producto del catálogo SmartWarehouse.',
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
            qty: _qty,
            maxQty: maxQty,
            unitPrice: p.price,
            disabled: outOfStock,
            onQtyChanged: (v) => setState(() => _qty = v),
            onAdd: () {
              for (var i = 0; i < _qty; i++) {
                widget.onAddToCart(p);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${p.name} agregado al carrito')),
              );
            },
          ),
        ],
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
              child: Text(
                sku,
                style: SwText.mono(size: 13, color: SwColors.text3, letterSpacing: 0.05),
              ),
            ),
          ),
          SwIconButton(icon: Icons.favorite_border, onPressed: () {}),
          const SizedBox(width: 8),
          SwIconButton(icon: Icons.share_outlined, onPressed: () {}),
        ],
      ),
    );
  }
}

class _ShipsContextBlock extends StatelessWidget {
  const _ShipsContextBlock({required this.shipping});
  final Shipping shipping;

  @override
  Widget build(BuildContext context) {
    final cutoff = shipping.cutoffTime;
    final pickup = shipping.pickupLocation;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwColors.yellowSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: SwColors.yellowDark, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: SwText.body(size: 13, color: SwColors.text2, height: 1.4),
                children: [
                  TextSpan(
                    text: shipping.shipsToday ? 'Sale hoy ' : 'Sale al próximo turno ',
                    style: SwText.body(size: 13, color: SwColors.text, weight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: cutoff.isEmpty
                        ? '· Retiro en $pickup.'
                        : 'si la orden se confirma antes de $cutoff · Retiro en $pickup.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({required this.location});
  final ProductLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwColors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: SwColors.text, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación en depósito',
                  style: SwText.body(size: 12, color: SwColors.text3),
                ),
                const SizedBox(height: 2),
                Text(
                  'Zona ${location.idZone} · Línea ${location.idLine} · Posición ${location.idPosition} · Altura ${location.height}',
                  style: SwText.body(size: 13, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
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
        children: List.generate(_DetailViewState._tabs.length, (i) {
          final isActive = i == active;
          return Padding(
            padding: EdgeInsets.only(right: i < _DetailViewState._tabs.length - 1 ? 24 : 0),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? SwColors.yellow : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _DetailViewState._tabs[i],
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
    // Combina specs propias del contrato + SKU + categoría como filas base.
    final entries = <(String, String)>[
      ('SKU', product.sku),
      ('Categoría', product.category.name),
      ('Stock disponible', '${product.stock.available}'),
      ('Máx. por orden', '${product.orderConstraints.maxQuantityPerOrder}'),
      ('Precio unitario', product.price.formatted),
      if (product.specs != null)
        for (final s in product.specs!) (s.label, s.value),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: SwColors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(SwRadii.card),
        boxShadow: SwShadows.card,
      ),
      child: Column(
        children: [
          for (final (i, e) in entries.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: i < entries.length - 1
                    ? const Border(bottom: BorderSide(color: SwColors.border))
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(e.$1, style: SwText.body(size: 14, color: SwColors.text3))),
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
    final label = 'Add to order · ${total.formatted}';
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
              child: SwButton(
                label: label,
                icon: Icons.add,
                onPressed: disabled ? null : onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
