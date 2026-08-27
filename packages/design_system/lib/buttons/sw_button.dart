import 'package:design_system/indicators/sw_loading_spinner.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SwButtonVariant { primary, secondary, ghost }

/// Brand-styled button. Primary = yellow on dark text; secondary = white with
/// border; ghost = transparent text-only. Matches the design system spec
/// (radius 12, 14×18 padding, Poppins 600).
class SwButton extends StatelessWidget {
  const SwButton({
    required this.label,
    required this.onPressed,
    this.variant = SwButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SwButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;
    final bg = switch (variant) {
      SwButtonVariant.primary => SwColors.yellow,
      SwButtonVariant.secondary => SwColors.white,
      SwButtonVariant.ghost => Colors.transparent,
    };
    final fg = SwColors.text;
    final border = variant == SwButtonVariant.secondary
        ? Border.all(color: SwColors.border)
        : null;

    return Opacity(
      opacity: disabled && !isLoading ? 0.5 : 1.0,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 10 : SwRadii.input),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(compact ? 10 : SwRadii.input),
          child: Container(
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(compact ? 10 : SwRadii.input),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SwLoadingSpinner(
                    size: 18,
                    strokeWidth: 2,
                    color: SwColors.text,
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: compact ? 16 : 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 14 : 16,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
