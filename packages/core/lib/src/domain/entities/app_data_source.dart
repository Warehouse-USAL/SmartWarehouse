import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_data_source.freezed.dart';

@freezed
sealed class AppDataSource with _$AppDataSource {
  const factory AppDataSource.mock() = MockAppDataSource;

  const factory AppDataSource.remote() = RemoteAppDataSource;

  const AppDataSource._();

  factory AppDataSource.fromString(String value) {
    switch (value) {
      case 'mock':
        return const AppDataSource.mock();
      case 'remote':
        return const AppDataSource.remote();
      default:
        return const AppDataSource.mock();
    }
  }
}
