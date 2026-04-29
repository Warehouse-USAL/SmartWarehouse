import 'package:beamer/beamer.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login/login.dart';
import 'package:upgrader/upgrader.dart';

/// Beamer configuration helper for navigation routing.
///
/// This class sets up all routes for the SmartWarehouse application.
/// Add your feature routes here as the app grows.
class BeamerConfigHelper implements NavigationConfigHelper<BeamerDelegate> {
  @override
  BeamerDelegate get delegate => BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: _buildRoutes(),
        ),
        guards: [
          // TODO: Uncomment and use authentication guards as needed
          // AuthenticatedGuard().guard,
          // NotAuthenticatedGuard().guard,
        ],
        notFoundPage: _buildNotFoundPage('not-found'),
        initialPath: Routes.login,
      );

  BeamPage _buildNotFoundPage(String route) {
    return _beamerPage(
      title: 'Not Found',
      key: 'not-found',
      child: const Scaffold(
        body: Center(child: Text('404 - Page not found')),
      ),
    );
  }

  Map<Pattern, dynamic Function(BuildContext, BeamState, Object?)> _buildRoutes() {
    return {
      Routes.login: (_, __, ___) {
        return _beamerPage(
          title: 'Login',
          key: 'login',
          child: LoginFeatureBuilder.buildPage(),
        );
      },
      Routes.home: (_, __, ___) {
        return _beamerPage(
          title: 'Home',
          key: 'home',
          child: const Scaffold(
            body: Center(
              child: Text('Home - TODO: Implement home feature'),
            ),
          ),
        );
      },
      // TODO: Add your feature routes here
      // Example:
      // Routes.orders: (_, state, __) {
      //   return _beamerPage(
      //     title: 'Orders',
      //     key: 'orders',
      //     child: OrdersFeatureBuilder.buildPage(),
      //   );
      // },
    };
  }

  BeamPage _beamerPage({
    required String title,
    required String key,
    required Widget child,
  }) {
    return BeamPage(
      title: title,
      key: ValueKey(key),
      name: key,
      child: UpgradeAlert(
        upgrader: Upgrader(
          minAppVersion: '1.0.0',
          debugLogging: kDebugMode,
          countryCode: 'US',
        ),
        child: child,
      ),
    );
  }
}
