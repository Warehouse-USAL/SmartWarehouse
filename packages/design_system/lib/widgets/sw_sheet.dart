import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Bottom sheet de marca: fondo blanco, radio superior `largeInput`, barrier
/// oscuro de marca y handle de arrastre arriba. Reemplaza a los
/// `showModalBottomSheet` crudos.
class SwSheet {
  const SwSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: SwColors.white,
      barrierColor: SwColors.text.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SwRadii.largeInput),
        ),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SwSheetHandle(),
          Flexible(child: builder(ctx)),
        ],
      ),
    );
  }
}

/// Handle de arrastre estándar de los sheets (36×4, gris de borde).
class SwSheetHandle extends StatelessWidget {
  const SwSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        color: SwColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
