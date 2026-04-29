import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class BottomNavigationScaffold extends StatelessWidget {
  const BottomNavigationScaffold({
    required this.selectedTab,
    required this.child,
    this.appBar,
    this.alignment,
    this.scrollable = true,
    this.appbar,
    this.showBottomNavigationBar = true,
    super.key,
  });

  final NavigationBarOption selectedTab;
  final PreferredSizeWidget? appbar;
  final Widget child;
  final bool scrollable, showBottomNavigationBar;
  final AlignmentGeometry? alignment;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final bottomNavigationBar = BottomNavigationBarFeatureBuilder.build(context, selectedTab);
    return Scaffold(
      appBar: appBar,
      backgroundColor: const Color(0xFFFCF7F7),
      body: SafeArea(
        child: Stack(
          alignment: alignment ?? AlignmentDirectional.topStart,
          children: [
            scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 56, top: 12),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        child,
                        if (showBottomNavigationBar)
                          IgnorePointer(child: Opacity(opacity: 0, child: bottomNavigationBar)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 56, top: 12),
                    child: child,
                  ),
            if (showBottomNavigationBar)
              Align(
                alignment: Alignment.bottomCenter,
                child: bottomNavigationBar,
              ),
          ],
        ),
      ),
    );
  }
}
