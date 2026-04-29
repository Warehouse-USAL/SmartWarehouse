import 'package:beamer/beamer.dart';
import 'package:flutter/cupertino.dart';

abstract class CustomBeamerGuard {
  BeamGuard get guard;

  static bool isCurrentRoute(BuildContext context, String route) {
    final currentLocation = Beamer.of(context).currentBeamLocation;
    return currentLocation.state.routeInformation.uri.path == route;
  }
}
