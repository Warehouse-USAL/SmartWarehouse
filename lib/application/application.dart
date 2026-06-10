import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:core/core.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SmartWarehouseApp extends StatefulWidget {
  const SmartWarehouseApp({super.key});

  @override
  State<SmartWarehouseApp> createState() => _SmartWarehouseAppState();
}

class _SmartWarehouseAppState extends State<SmartWarehouseApp> {
  final _routerDelegate = Injector.i.resolve<NavigationConfigHelper<BeamerDelegate>>().delegate;
  bool _showSplashMinTimer = true;
  bool _splashDismissed = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() => _showSplashMinTimer = false);
      _removeSplashIfNeeded();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeSplashIfNeeded();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    });
  }

  void _removeSplashIfNeeded() {
    if (!_showSplashMinTimer && !_splashDismissed) {
      _splashDismissed = true;
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFeatureBuilder.listenerWrapper(
      onUserAuthenticated: _onUserAuthenticated,
      onUserLoggedOut: _onUserLoggedOut,
      child: GestureDetector(
        onTap: () => _onUnfocus(context),
        child: MaterialApp.router(
          routerDelegate: _routerDelegate,
          routeInformationParser: BeamerParser(),
          theme: ThemeData(extensions: [SmartWarehouseTheme().themeExtension]),
          debugShowCheckedModeBanner: false,
          backButtonDispatcher: BeamerBackButtonDispatcher(
            delegate: _routerDelegate,
            alwaysBeamBack: true,
          ),
          title: 'SmartWarehouse',
          // NOTA: antes acá envolvíamos child con
          // OrderTrackingFeatureBuilder.buildNotificationListener para
          // mostrar una SnackBar in-app por cada notificación.
          // Pero ese BlocListener estaba arriba del Navigator → al rebuildear
          // el padre, el Navigator ejecutaba didUpdateWidget → _updatePages
          // con el NoAnimationTransitionDelegate cacheado de Beamer, que
          // tiene un bug en markForRemove ("This route cannot be marked for
          // complete"). Se eliminó. Las notificaciones siguen llegando al
          // cubit, el badge de la campana se actualiza y la página
          // /notifications las lista. Si querés re-habilitar la SnackBar,
          // hay que reimplementarla con un GlobalKey<ScaffoldMessengerState>
          // afuera del árbol del Navigator.
          builder: (_, child) => child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  void _onUnfocus(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) currentFocus.focusedChild?.unfocus();
  }

  void _onUserLoggedOut() {
    final context = _navigatorContext;
    if (context == null) return;
    OnLoginNavigationUseCase.call(context);
  }

  void _onUserAuthenticated() {
    final context = _navigatorContext;
    if (context == null) return;
    OnUserAuthenticatedUseCase.call(context);
    OrderTrackingFeatureBuilder.startNotifications();
  }

  BuildContext? get _navigatorContext => _routerDelegate.navigatorKey.currentContext;
}
