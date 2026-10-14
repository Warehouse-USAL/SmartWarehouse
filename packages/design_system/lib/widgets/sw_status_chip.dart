import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Chip de estado con punto de color — el patrón del badge de stock del
/// catálogo, generalizado. Las features definen el mapeo estado→colores
/// (p. ej. orden cancelada = danger sobre dangerSoft).
class SwStatusChip extends StatelessWidget {
  const SwStatusChip({
    required this.label,
    required this.color,
    required this.background,
    this.dot = true,
    super.key,
  });

  final String label;

  /// Color del texto y del punto.
  final Color color;

  final Color background;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SwRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: SwText.body(
              size: 11.5,
              weight: FontWeight.w600,
            ).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
