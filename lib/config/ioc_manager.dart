import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:commons/helpers/build_data/build_data_helper.dart';
import 'package:commons/helpers/build_data/package_info_build_data_helper.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/permissions_handler_helper.dart';
import 'package:commons/helpers/permissions/permissions_helper.dart';
import 'package:commons/helpers/persistence_helper/hive_persistence_helper.dart';
import 'package:core/core.dart';
import 'package:profile/profile.dart';
import 'package:smart_warehouse/application/navigation/beamer_config_helper.dart';

/// IoC (Inversion of Control) manager for dependency registration.
///
/// This class registers all singleton and lazy-singleton dependencies
/// used throughout the SmartWarehouse application.
class IocManager {
  static Future<void> register({required EnvironmentConfig config}) async {
    Injector.i
      ..registerSingleton<ExternalUrls>(
        config.environment.maybeWhen(orElse: ExternalUrls.new),
      )
      ..registerSingleton<EnvironmentConfig>(config)
      ..registerSingleton<AppDataSource>(config.dataSource)
      ..registerSingleton<PersistenceHelper>(HivePersistenceHelper('smart-warehouse'))
      ..registerLazySingleton<PermissionsHelper>(PermissionsHandlerHelper.new)
      ..registerLazySingleton<BuildDataHelper>(
        () => PackageInfoBuildDataHelper(
          environmentData: EnvironmentData(key: 'environment', defaultValue: 'dev'),
        ),
      )
      ..registerLazySingleton<HttpHelper>(
        () => DioHttpHelper(
          baseUrl: config.environment.when(
            dev: _localBackendUrl,
            qa: _localBackendUrl,
            prod: _localBackendUrl,
          ),
          onRefreshToken: AuthFeatureBuilder.refreshToken,
          isExpiredToken: AuthFeatureBuilder.isExpiredToken,
          connectTimeout: const Duration(milliseconds: 20000),
          receiveTimeout: const Duration(milliseconds: 20000),
          debuggingInterceptors: [LoggingInterceptor()],
          domainInterceptors: [
            AuthInterceptor(requestInterceptionData: OnInterceptHttpRequestUseCase.call),
          ],
        )..init(),
      )
      ..registerSingleton<ImagePickerHelper>(ImagePickerHelperImplementation())
      ..registerSingleton<NavigationHelper>(BeamerNavigationHelper())
      ..registerSingleton<NavigationConfigHelper<BeamerDelegate>>(BeamerConfigHelper())
      ..registerSingleton<TokenRepository>(
        LocalTokenRepository(onGetTokenUseCase: OnGetTokenUseCase.call),
      );

    AuthFeatureBuilder.injectDependencies();
    CatalogFeatureBuilder.injectDependencies();
    OrdersFeatureBuilder.injectDependencies();
    CartFeatureBuilder.injectDependencies();
    OrderTrackingFeatureBuilder.injectDependencies(
      baseUrl: config.environment.when(
        dev: _localBackendUrl,
        qa: _localBackendUrl,
        prod: _localBackendUrl,
      ),
    );
    ProfileFeatureBuilder.injectDependencies();
  }
}

/// URL del backend.
///
/// Precedence (de mayor a menor):
/// 1. `--dart-define=API_BASE_URL=https://api.example.com` — URL completa con
///    scheme. Usado en builds de release / APK demo para apuntar al back
///    público.
/// 2. `--dart-define=API_HOST=192.168.1.10 --dart-define=API_PORT=8080` —
///    útil para device físico en red local (asume http://).
/// 3. Defaults locales: `10.0.2.2:8080` para Android emulator (alias mágico
///    al host), `localhost:8080` para iOS simulator / desktop / web.
String _localBackendUrl() {
  // Override absoluto: la URL ya viene con scheme + host + (port opcional) +
  // (path opcional). Se respeta tal cual.
  const fullOverride = String.fromEnvironment('API_BASE_URL');
  if (fullOverride.isNotEmpty) return fullOverride;

  const overrideHost = String.fromEnvironment('API_HOST');
  const overridePort = String.fromEnvironment('API_PORT', defaultValue: '8080');
  if (overrideHost.isNotEmpty) {
    return 'http://$overrideHost:$overridePort';
  }
  if (kIsWeb) return 'http://localhost:$overridePort';
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:$overridePort';
}
