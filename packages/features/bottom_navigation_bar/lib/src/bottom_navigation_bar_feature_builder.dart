import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_component.dart';
import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_scaffold.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarFeatureBuilder {
  static Widget build(BuildContext context, NavigationBarOption selectedTab) {
    return BottomNavigationComponent(
      selectedTab: selectedTab,
      onItemPressed: (context, option) {
        option.when(
          products: () => Beamer.of(context).beamToNamed(Routes.catalog),
          cart: () => Beamer.of(context).beamToNamed(Routes.cart),
          orders: () => Beamer.of(context).beamToNamed(Routes.orders),
          profile: () => Beamer.of(context).beamToNamed(Routes.profile),
        );
      },
    );
  }

  static Widget buildScaffold(
    BuildContext context, {
    required NavigationBarOption selectedTab,
    required Widget child,
    PreferredSizeWidget? appBar,
    bool showNavigationBar = true,
    bool scrollable = true,
    Alignment? alignment,
  }) {
    return BottomNavigationScaffold(
      alignment: alignment,
      selectedTab: selectedTab,
      scrollable: scrollable,
      appBar: appBar,
      showBottomNavigationBar: showNavigationBar,
      child: child,
    );
  }
}
