import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_environment.freezed.dart';

@freezed
sealed class AppEnvironment with _$AppEnvironment {
  const factory AppEnvironment.dev() = DevEnvironment;

  const factory AppEnvironment.prod() = ProdEnvironment;

  const factory AppEnvironment.qa() = QAEnvironment;

  factory AppEnvironment.fromString(String? env) {
    switch (env) {
      case 'dev':
        return const AppEnvironment.dev();
      case 'qa':
        return const AppEnvironment.qa();
      case 'prod':
        return const AppEnvironment.prod();
      default:
        return const AppEnvironment.dev();
    }
  }
}

class EnvironmentConfig {
  EnvironmentConfig({
    required this.environment,
    required this.dataSource,
  });

  factory EnvironmentConfig.fromEnvVariables() {
    const dataSourceEnv = String.fromEnvironment('data_source');
    const appDataSourceEnv = String.fromEnvironment('APP_DATA_SOURCE');

    final dataSource = dataSourceEnv.isNotEmpty
        ? AppDataSource.fromString(dataSourceEnv)
        : appDataSourceEnv.isNotEmpty
            ? AppDataSource.fromString(appDataSourceEnv)
            : const AppDataSource.remote();

    return EnvironmentConfig(
      environment: AppEnvironment.fromString(appFlavor),
      dataSource: dataSource,
    );
  }

  final AppEnvironment environment;
  final AppDataSource dataSource;
}
