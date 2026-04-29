import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.boxShadow,
    this.backgroundColor,
    this.pressedColor,
    this.iconPadding,
    this.radius,
  });

  final Color? backgroundColor, pressedColor;
  final CustomIcon icon;
  final BorderRadius? radius;
  final VoidCallback onPressed;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets? iconPadding;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final borderRadius = radius ?? BorderRadius.circular(8);
    return Container(
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        borderRadius: borderRadius,
      ),
      child: PressableWidget(
        onPressed: onPressed,
        pressedColor: pressedColor,
        backgroundColor: backgroundColor ?? theme.primaryWhite,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
          ),
          child: Padding(padding: iconPadding ?? const EdgeInsets.all(6), child: icon),
        ),
      ),
    );
  }
}
