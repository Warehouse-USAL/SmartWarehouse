import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Botón cuadrado de 40×40 con borde redondeado, sobre `SwColors.surface`.
/// Acepta un `badge` opcional (típicamente [SwBadge] o un punto de color)
/// que se renderiza en la esquina superior derecha.
class SwIconButton extends StatelessWidget {
  const SwIconButton({
    required this.icon,
    required this.onPressed,
    this.badge,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Widget? badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: SwColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                Center(child: Icon(icon, size: 20, color: SwColors.text)),
                if (badge != null)
                  Positioned(top: -4, right: -4, child: badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Contador en formato pill para superponer sobre [SwIconButton] (carrito,
/// notificaciones). No renderiza nada si `count <= 0`.
class SwBadge extends StatelessWidget {
  const SwBadge({required this.count, super.key});
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: SwColors.yellow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SwColors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: SwText.body(size: 10, weight: FontWeight.w700, color: SwColors.text),
      ),
    );
  }
}
