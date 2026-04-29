import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class BaseCustomList extends StatelessWidget {
  const BaseCustomList({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.black10),
      ),
      child: child,
    );
  }
}
