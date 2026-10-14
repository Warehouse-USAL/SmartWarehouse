import 'dart:async';

import 'package:catalog/src/domain/entities/product.dart';
import 'package:catalog/src/presentation/widgets/product_card.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "Suelen llevarse juntos" — carrusel horizontal de productos recomendados
/// al pie del detalle de producto.
///
/// Se desliza solo, despacio, y se frena apenas el usuario lo toca (vuelve a
/// moverse al soltar). Si el loader devuelve vacío o falla, la sección entera
/// desaparece: nunca un estado de error por algo accesorio.
class RecommendationsCarousel extends StatefulWidget {
  const RecommendationsCarousel({
    required this.load,
    required this.onProductTap,
    this.autoScroll = true,
    super.key,
  });

  /// Trae las recomendaciones. Lo inyecta la capa de aplicación — catalog
  /// no sabe de órdenes ni del algoritmo.
  final Future<List<Product>> Function() load;

  final void Function(Product product) onProductTap;

  /// Apagable en tests (el timer infinito no deja asentar el árbol).
  final bool autoScroll;

  @override
  State<RecommendationsCarousel> createState() =>
      _RecommendationsCarouselState();
}

class _RecommendationsCarouselState extends State<RecommendationsCarousel> {
  final _controller = ScrollController();
  List<Product> _products = const [];
  Timer? _ticker;
  bool _userTouching = false;

  @override
  void initState() {
    super.initState();
    widget
        .load()
        .then((products) {
          if (!mounted) return;
          setState(() => _products = products);
          if (widget.autoScroll && products.length > 2) _startTicker();
        })
        .catchError((Object _) {
          // El loader ya promete no lanzar; esto es cinturón y tiradores.
        });
  }

  void _startTicker() {
    // Avance continuo suave: ~30 px/seg. Al llegar al final vuelve al
    // principio con un salto animado largo (no hay loop infinito de items:
    // mantener la lista real simplifica el tap y la accesibilidad).
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _userTouching || !_controller.hasClients) return;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      final next = _controller.offset + 1.5;
      if (next >= max) {
        _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      } else {
        _controller.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Suelen llevarse juntos', style: SwText.display(size: 18)),
              const SizedBox(height: 2),
              Text(
                'Basado en pedidos que incluyeron este producto',
                style: SwText.body(size: 12, color: SwColors.text3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 236,
          child: Listener(
            onPointerDown: (_) => _userTouching = true,
            onPointerUp: (_) => _userTouching = false,
            onPointerCancel: (_) => _userTouching = false,
            child: ListView.separated(
              key: E2eKeys.recommendationsCarousel,
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = _products[index];
                return SizedBox(
                  width: 150,
                  child: ProductCard(
                    product: product,
                    tinted: index.isEven,
                    onTap: () => widget.onProductTap(product),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
