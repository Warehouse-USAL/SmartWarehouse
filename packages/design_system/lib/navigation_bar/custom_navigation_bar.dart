import 'package:design_system/navigation_bar/navigation_item.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({required this.items, super.key});

  final List<NavigationItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = CustomThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.primaryBlack, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((e) => Expanded(child: e)).toList(),
      ),
    );
  }
}
