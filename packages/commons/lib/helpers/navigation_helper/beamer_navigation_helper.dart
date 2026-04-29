import 'package:beamer/beamer.dart';
import 'package:commons/helpers/navigation_helper/navigation_helper.dart';
import 'package:flutter/material.dart';

class BeamerNavigationHelper implements NavigationHelper {
  @override
  void pop(BuildContext context) => popToPreviousRoute(context);

  @override
  void popToPreviousRoute(BuildContext context) => Beamer.of(context).beamBack();

  @override
  void pushNamed(
    BuildContext context, {
    required String routeName,
    Map<String, dynamic>? data,
    bool disableAnimation = true,
    bool replace = false,
  }) {
    final beamer = Beamer.of(context);
    if (replace) {
      _clearHistory(beamer);
      beamer.beamToReplacementNamed(
        routeName,
        data: data,
        transitionDelegate: disableAnimation ? const NoAnimationTransitionDelegate() : null,
      );
    } else {
      beamer.beamToNamed(
        routeName,
        data: data,
        transitionDelegate: disableAnimation ? const NoAnimationTransitionDelegate() : null,
      );
    }
  }

  void _clearHistory(BeamerDelegate beamer) {
    final history = beamer.beamingHistory.first.history;
    history.removeRange(0, history.length - 1);
  }

  @override
  bool isCurrentRoute(BuildContext context, String route) {
    final beamer = Beamer.of(context);
    final currentLocation = beamer.currentBeamLocation;
    final location = currentLocation.state.routeInformation.uri.path;
    return location == route;
  }

  @override
  String currentPath(BuildContext context) => Beamer.of(context).currentBeamLocation.state.routeInformation.uri.path;

  @override
  bool canPop(BuildContext context) {
    final beamer = Beamer.of(context);
    final history = beamer.beamingHistory;
    final hist = history.first.history;
    return hist.length > 1;
  }
}
