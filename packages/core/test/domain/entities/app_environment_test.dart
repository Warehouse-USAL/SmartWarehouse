import 'package:core/src/domain/entities/app_data_source.dart';
import 'package:core/src/domain/entities/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.fromString', () {
    test('maps each known flavor', () {
      expect(AppEnvironment.fromString('dev'), const AppEnvironment.dev());
      expect(AppEnvironment.fromString('qa'), const AppEnvironment.qa());
      expect(AppEnvironment.fromString('prod'), const AppEnvironment.prod());
    });

    test('falls back to dev for unknown and null', () {
      expect(AppEnvironment.fromString('staging'), const AppEnvironment.dev());
      expect(AppEnvironment.fromString(null), const AppEnvironment.dev());
    });
  });

  group('EnvironmentConfig', () {
    test('holds the environment and data source it was built with', () {
      final config = EnvironmentConfig(
        environment: const AppEnvironment.qa(),
        dataSource: const AppDataSource.mock(),
      );

      expect(config.environment, const AppEnvironment.qa());
      expect(config.dataSource.isMock, isTrue);
    });

    test('fromEnvVariables defaults to remote when no dart-define is set', () {
      // No --dart-define is passed by `flutter test`, so both env lookups are
      // empty and the remote default applies.
      final config = EnvironmentConfig.fromEnvVariables();

      expect(config.dataSource.isRemote, isTrue);
    });
  });
}
