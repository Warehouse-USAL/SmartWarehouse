import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// A reusable empty state view for the whole app.
///
/// It shows an icon, a title, a descriptive message, and an optional
/// Call To Action (CTA) button.
class SwEmptyView extends StatelessWidget {
  const SwEmptyView({
    required this.title,
    required this.message,
    this.icon = Icons.inventory_2_outlined,
    this.ctaLabel,
    this.onCtaPressed,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: SwColors.text3.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: SwText.display(size: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: SwText.body(size: 14, color: SwColors.text3),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: 24),
              SwButton(
                label: ctaLabel!,
                onPressed: onCtaPressed!,
                variant: SwButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
