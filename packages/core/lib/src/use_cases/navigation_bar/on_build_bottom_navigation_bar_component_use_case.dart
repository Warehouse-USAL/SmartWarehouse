import 'package:bottom_navigation_bar/bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';

class OnBuildBottomNavigationBarComponentUseCase {
  static Widget call(BuildContext context, NavigationBarOption selectedTab) =>
      BottomNavigationBarFeatureBuilder.build(context, selectedTab);
}
