import 'package:bottom_navigation_bar/src/domain/entities/navigation_bar_option.dart';
import 'package:design_system/icon/custom_icon.dart';
import 'package:design_system/navigation_bar/custom_navigation_bar.dart';
import 'package:design_system/navigation_bar/navigation_item.dart';
import 'package:flutter/material.dart';

class BottomNavigationComponent extends StatelessWidget {
  const BottomNavigationComponent({
    required this.selectedTab,
    required this.onItemPressed,
    super.key,
  });

  final Function(BuildContext context, NavigationBarOption option) onItemPressed;
  final NavigationBarOption selectedTab;

  @override
  Widget build(BuildContext context) {
    const home = NavigationBarOption.home();
    // TODO: Add more navigation items as needed
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: CustomNavigationBar(
        items: [
          NavigationItem(
            icon: CustomIconData.home,
            isActive: selectedTab == home,
            onPressed: () => onItemPressed(context, home),
            title: 'Home',
            selectedIcon: CustomIconData.selectedHome,
          ),
          // TODO: Add more navigation items here
          // Example:
          // NavigationItem(
          //   icon: CustomIconData.orders,
          //   isActive: selectedTab == orders,
          //   onPressed: () => onItemPressed(context, orders),
          //   title: 'Orders',
          //   selectedIcon: CustomIconData.ordersFilled,
          // ),
        ],
      ),
    );
  }
}
