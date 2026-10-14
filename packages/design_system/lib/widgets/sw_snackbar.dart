import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// SnackBar de marca: flotante, fondo oscuro, radio 12, ícono en tile
/// amarillo suave y acción en amarillo. Es el estilo que ya usaba la
/// notificación de cambio de estado de órdenes — acá queda como el canon
/// para toda la app, en lugar de los `SnackBar` grises default.
class SwSnackBar {
  const SwSnackBar._();

  /// Arma el `SnackBar` brandeado. [message] es la línea principal;
  /// [detail] una segunda línea en amarillo (p. ej. "1 sin stock quedó
  /// afuera"); [actionLabel]/[onAction] el botón de la derecha.
  static SnackBar build({
    required String message,
    String? detail,
    IconData icon = Icons.info_outline,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SwColors.text,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
      content: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SwColors.yellowSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: SwColors.yellowDark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SwText.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: SwColors.white,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwText.body(size: 11, color: SwColors.yellow),
                  ),
              ],
            ),
          ),
        ],
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: SwColors.yellow,
              onPressed: onAction ?? () {},
            ),
    );
  }

  /// Muestra el snackbar en el messenger del [context].
  static void show(
    BuildContext context, {
    required String message,
    String? detail,
    IconData icon = Icons.info_outline,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      build(
        message: message,
        detail: detail,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
  }

  /// Variante de error: mismo estilo, ícono de alerta en tile rojo suave.
  static SnackBar buildError({
    required String message,
    String? detail,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    final base = build(
      message: message,
      detail: detail,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
    return SnackBar(
      behavior: base.behavior,
      backgroundColor: base.backgroundColor,
      margin: base.margin,
      shape: base.shape,
      duration: base.duration,
      action: base.action,
      content: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: SwColors.dangerSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 18,
              color: SwColors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SwText.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: SwColors.white,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwText.body(size: 11, color: SwColors.yellow),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra la variante de error en el messenger del [context].
  static void showError(
    BuildContext context, {
    required String message,
    String? detail,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      buildError(
        message: message,
        detail: detail,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
