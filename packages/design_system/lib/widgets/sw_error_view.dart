import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A reusable error view for the whole app.
///
/// It shows an error icon, a message, and a retry button.
class SwErrorView extends StatelessWidget {
  const SwErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: SwColors.stockOut,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: SwText.body(size: 15, color: SwColors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SwButton(
              label: 'Reintentar',
              variant: SwButtonVariant.secondary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
