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
import 'package:smart_warehouse/config/backend_url.dart';

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

/// URL del backend. Ver [resolveBackendUrl] para la precedencia.
String _localBackendUrl() => resolveBackendUrl(
  isWeb: kIsWeb,
  // Platform.isAndroid lanza en web: el short-circuit lo protege.
  isAndroid: !kIsWeb && Platform.isAndroid,
  base: Uri.base,
  fullOverride: const String.fromEnvironment('API_BASE_URL'),
  hostOverride: const String.fromEnvironment('API_HOST'),
  port: const String.fromEnvironment('API_PORT', defaultValue: '8080'),
);
