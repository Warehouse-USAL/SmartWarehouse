import 'package:design_system/testing/e2e_keys.dart';
import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Flat white bottom nav per the SmartWarehouse design system: 1px top border,
/// 4 columns by default, outlined icons + 11px labels, active = dark text.
class SwBottomNav extends StatelessWidget {
  const SwBottomNav({required this.tabs, required this.activeId, required this.onTabSelected, super.key});

  final List<SwNavTab> tabs;
  final String activeId;
  final void Function(String tabId) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SwColors.white,
        border: Border(top: BorderSide(color: SwColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: SafeArea(
        top: false,
        child: Row(
          children: tabs
              .map((t) => Expanded(
                    child: _NavItem(
                      key: E2eKeys.navTab(t.id),
                      tab: t,
                      isActive: t.id == activeId,
                      onTap: () => onTabSelected(t.id),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class SwNavTab {
  const SwNavTab({required this.id, required this.label, required this.icon, this.badgeCount = 0});
  final String id;
  final String label;
  final IconData icon;
  final int badgeCount;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.isActive, required this.onTap, super.key});
  final SwNavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? SwColors.text : SwColors.text3;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(tab.icon, size: 22, color: color),
                if (tab.badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: SwColors.yellow,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: SwColors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab.badgeCount > 99 ? '99+' : '${tab.badgeCount}',
                        style: SwText.body(size: 10, weight: FontWeight.w700, color: SwColors.text),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(tab.label, style: SwText.body(size: 11, weight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
