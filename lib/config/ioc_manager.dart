import 'package:beamer/beamer.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/build_data/build_data_helper.dart';
import 'package:commons/helpers/build_data/package_info_build_data_helper.dart';
import 'package:commons/helpers/permissions/permissions_handler_package/permissions_handler_helper.dart';
import 'package:commons/helpers/permissions/permissions_helper.dart';
import 'package:commons/helpers/persistence_helper/hive_persistence_helper.dart';
import 'package:core/core.dart';
import 'package:smart_warehouse/application/navigation/beamer_config_helper.dart';
import 'package:token_repository/token_repository.dart';

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
            dev: () => 'https://api.smartwarehouse.dev/v1',
            qa: () => 'https://api-qa.smartwarehouse.dev/v1',
            prod: () => 'https://api.smartwarehouse.dev/v1',
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
  }
}
