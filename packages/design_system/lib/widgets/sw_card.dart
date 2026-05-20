import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Card del design system. Fondo blanco, borde sutil, esquinas redondeadas
/// (`SwRadii.card`) y sombra ligera (`SwShadows.card`). `padding` opcional para
/// que el contenido no tenga que envolverse en otro Padding.
class SwCard extends StatelessWidget {
  const SwCard({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = padding == null ? child : Padding(padding: padding!, child: child);
    return Container(
      decoration: BoxDecoration(
        color: SwColors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(SwRadii.card),
        boxShadow: SwShadows.card,
      ),
      child: content,
    );
  }
}
