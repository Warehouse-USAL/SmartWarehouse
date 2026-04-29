import 'package:design_system/design_system.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    required this.icon,
    required this.isActive,
    required this.title,
    required this.onPressed,
    required this.selectedIcon,
    super.key,
  });

  final bool isActive;
  final CustomIconData icon, selectedIcon;
  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final style = CustomTextStyles.of(context);
    return PressableWidget(
      onPressed: onPressed,
      backgroundColor: theme.primaryBlack,
      pressedColor: Colors.transparent,
      child: SizedBox(
        width: 66,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIcon(
                data: isActive ? selectedIcon : icon,
                size: const Size(28, 28),
                color: theme.primaryWhite,
              ),
              const SizedBox(height: 2),
              CustomText(
                title,
                style: style.f10W700.value.copyWith(color: theme.primaryWhite,fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
