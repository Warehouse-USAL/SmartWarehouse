import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class CustomCircularIcon extends StatelessWidget {
  const CustomCircularIcon({required this.iconData, super.key});

  final CustomIconData iconData;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.black10),
      ),
      child: CustomIcon(data: iconData, size: const Size(32, 32)),
    );
  }
}
