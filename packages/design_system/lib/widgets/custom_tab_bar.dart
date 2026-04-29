import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/widgets/pressable_widget.dart';
import 'package:design_system/widgets/spaces/custom_spacer.dart';
import 'package:design_system/widgets/text/custom_text.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({required this.items, super.key});

  final List<TabItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.tertiary200,
          border: Border.all(color: theme.black10),
        ),
        child: Row(children: items),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({
    required this.title,
    required this.onPressed,
    this.badgeCount = 0,
    this.isActive = false,
    this.data,
    super.key,
  });

  final CustomIconData? data;
  final String title;
  final int badgeCount;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    final style = CustomTextStyles.of(context);
    final activeBoxShadow = [
      const BoxShadow(
        color: Color(0x1A000000),
        offset: Offset(0, 1),
        blurRadius: 5,
      ),
    ];
    return Expanded(
      child: PressableWidget(
        backgroundColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            boxShadow: isActive ? activeBoxShadow : null,
            borderRadius: BorderRadius.circular(12),
            color: isActive ? theme.primaryWhite : Colors.transparent,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (data != null)
                  CustomIcon(
                    data: data!,
                    size: const Size(20, 20),
                    color: isActive ? theme.primaryBlack : theme.gray500,
                  ),
                const CustomSpacer(width: CustomSpace.x1),
                CustomText(title, style: style.f14W600PJS.value.copyWith(color: isActive ? null : theme.gray500)),
                if (badgeCount > 0) ...[
                  const CustomSpacer(width: CustomSpace.x1),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: theme.negative300, shape: BoxShape.circle),
                    child: CustomText(
                      textAlign: TextAlign.center,
                      badgeCount.toString(),
                      style: style.f10W500.value.copyWith(color: theme.primaryWhite),
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
