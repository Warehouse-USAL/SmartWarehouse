import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:commons/helpers/build_data/build_data_helper.dart';
import 'package:commons/helpers/build_data/package_info_build_data_helper.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/permissions_handler_helper.dart';
import 'package:commons/helpers/permissions/permissions_helper.dart';
import 'package:commons/helpers/persistence_helper/hive_persistence_helper.dart';
import 'package:core/core.dart';
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
  }
}

/// URL del backend cuando corre en `localhost` del host de desarrollo.
///
/// El emulator Android no ve `localhost` de la máquina anfitriona — para él
/// `localhost` es el propio emulator. Se debe usar `10.0.2.2` (alias mágico
/// que Android le da al host). En iOS simulator y desktop, `localhost`
/// funciona porque comparten network stack.
///
/// Para device físico, pasar la IP de tu máquina en la red local con
/// `--dart-define=API_HOST=192.168.x.x` (y opcional `API_PORT=8080`).
String _localBackendUrl() {
  const overrideHost = String.fromEnvironment('API_HOST');
  const overridePort = String.fromEnvironment('API_PORT', defaultValue: '8080');
  if (overrideHost.isNotEmpty) {
    return 'http://$overrideHost:$overridePort';
  }
  if (kIsWeb) return 'http://localhost:$overridePort';
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  return 'http://$host:$overridePort';
}
