import 'package:design_system/design_system.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    required this.text,
    required this.iconData,
    required this.onPressed,
    super.key,
  });

  final String text;
  final CustomIconData iconData;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return PressableWidget(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.black10),
        ),
        child: Row(
          children: [
            CustomIcon(data: iconData, size: const Size(24, 24), color: theme.primaryBlack),
            const CustomSpacer(width: CustomSpace.x2),
            CustomText(text, styleBuilder: (style) => style.f16W500),
          ],
        ),
      ),
    );
  }
}
