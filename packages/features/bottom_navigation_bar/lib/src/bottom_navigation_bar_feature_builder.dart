import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_component.dart';
import 'package:bottom_navigation_bar/src/presentation/components/bottom_navigation_scaffold.dart';
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';

class BottomNavigationBarFeatureBuilder {
  static Widget build(BuildContext context, NavigationBarOption selectedTab) {
    return BottomNavigationComponent(
      selectedTab: selectedTab,
      onItemPressed: (context, option) {
        option.when(
          home: () {
            // TODO: Implement home navigation
            // OnHomeNavigationUseCase.call(context);
          },
          // TODO: Add more navigation options as needed
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
