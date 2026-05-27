import 'package:beamer/beamer.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_warehouse/application/navigation/guards/auth/authenticated_guard.dart';
import 'package:smart_warehouse/application/navigation/guards/auth/not_authenticated_guard.dart';
import 'package:upgrader/upgrader.dart';

class BeamerConfigHelper implements NavigationConfigHelper<BeamerDelegate> {
  @override
  BeamerDelegate get delegate => BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: _buildRoutes(),
        ).call,
        guards: [
          AuthenticatedGuard().guard,
          NotAuthenticatedGuard().guard,
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
          child: LoginFeatureBuilder.buildPage(
            onLoginSuccess: (context, tokens) async {
              await AuthFeatureBuilder.login(
                token: tokens.accessToken,
                refreshToken: tokens.refreshToken,
              );
            },
          ),
        );
      },
      Routes.profile: (_, __, ___) {
        return _beamerPage(
          title: 'Profile',
          key: 'profile',
          child: const Scaffold(
            body: Center(
              child: Text('Profile - TODO: Implement profile feature'),
            ),
          ),
        );
      },
      Routes.catalog: (_, __, ___) {
        return _beamerPage(
          title: 'Catálogo',
          key: 'catalog',
          child: CatalogFeatureBuilder.buildCatalogPage(),
        );
      },
      Routes.catalogDetailPattern: (_, state, __) {
        final id = state.pathParameters['id'] ?? '';
        return _beamerPage(
          title: 'Producto',
          key: 'catalog-detail-$id',
          child: CatalogFeatureBuilder.buildProductDetailPage(
            id,
            onAddToCart: CartFeatureBuilder.addToCart,
          ),
        );
      },
      Routes.cart: (_, __, ___) {
        return _beamerPage(
          title: 'Carrito',
          key: 'cart',
          child: CartFeatureBuilder.buildCartPage(),
        );
      },
      Routes.orderSuccessPattern: (_, state, __) {
        final id = state.pathParameters['id'] ?? '';
        return _beamerPage(
          title: 'Orden creada',
          key: 'order-success-$id',
          child: OrdersFeatureBuilder.buildOrderSuccessPage(id),
        );
      },
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
