import 'package:design_system/buttons/sw_button.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Diálogo de confirmación con el manual de marca: radio de card, sombra
/// elevada, título Poppins y acciones con [SwButton]. Reemplaza a los
/// `AlertDialog` crudos de Material.
///
/// Dos sabores vía [SwDialog.show]:
///  - normal: confirmar una acción (crear orden). Botón primario amarillo.
///  - [destructive]: la acción rompe algo (cancelar orden). Ícono rojo arriba
///    y botón sólido rojo — estrena `SwColors.danger`.
///
/// Devuelve `true` si el usuario confirmó; `false` si canceló o tocó afuera.
class SwDialog extends StatelessWidget {
  const SwDialog({
    required this.title,
    required this.confirmLabel,
    this.message,
    this.body,
    this.cancelLabel = 'Cancelar',
    this.destructive = false,
    this.confirmKey,
    this.cancelKey,
    super.key,
  });

  final String title;
  final String? message;

  /// Contenido extra entre el mensaje y las acciones (p. ej. la fila de
  /// total del diálogo de confirmar orden).
  final Widget? body;

  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final Key? confirmKey;
  final Key? cancelKey;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? message,
    Widget? body,
    String cancelLabel = 'Cancelar',
    bool destructive = false,
    Key? confirmKey,
    Key? cancelKey,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: SwColors.text.withValues(alpha: 0.45),
      builder: (_) => SwDialog(
        title: title,
        message: message,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        confirmKey: confirmKey,
        cancelKey: cancelKey,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SwColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SwRadii.card),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (destructive) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SwColors.dangerSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: SwColors.danger,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(title, style: SwText.display(size: 19)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: SwText.body(size: 13.5, color: SwColors.text3),
              ),
            ],
            if (body != null) ...[const SizedBox(height: 4), body!],
            const SizedBox(height: 16),
            Row(
              children: [
                SwButton(
                  key: cancelKey,
                  label: cancelLabel,
                  variant: SwButtonVariant.ghost,
                  compact: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwButton(
                    key: confirmKey,
                    label: confirmLabel,
                    variant: destructive
                        ? SwButtonVariant.danger
                        : SwButtonVariant.primary,
                    compact: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
