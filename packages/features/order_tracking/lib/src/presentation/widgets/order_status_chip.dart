import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:orders/orders.dart';

/// Chip de color del estado de una orden — antes todos los estados se
/// mostraban como texto gris indistinguible. Mapea el estado a los colores
/// de marca sobre el [SwStatusChip] genérico del design system.
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      OrderStatus.pending => (SwColors.yellowDark, SwColors.yellowSoft),
      OrderStatus.inProgress => (SwColors.infoText, SwColors.infoBg),
      OrderStatus.completed => (SwColors.stockIn, SwColors.okSoft),
      OrderStatus.cancelled => (SwColors.danger, SwColors.dangerSoft),
    };
    return SwStatusChip(
      label: status.label,
      color: color,
      background: background,
    );
  }
}
