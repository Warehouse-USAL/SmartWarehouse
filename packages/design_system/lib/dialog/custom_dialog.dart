import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.black10),
      ),
      backgroundColor: theme.primaryWhite,
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    bool barrierDismissible = true,
  }) {
    final theme = CustomThemeExtension.of(context);
    return showDialog(
      context: context,
      barrierColor: theme.primaryWhite.withOpacity(0.9),
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(padding: padding, child: child),
    );
  }
}
