import 'package:core/src/domain/entities/app_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromString maps mock', () {
    final source = AppDataSource.fromString('mock');

    expect(source.isMock, isTrue);
    expect(source.isRemote, isFalse);
  });

  test('fromString maps remote', () {
    final source = AppDataSource.fromString('remote');

    expect(source.isRemote, isTrue);
    expect(source.isMock, isFalse);
  });

  test('fromString falls back to mock for an unknown value', () {
    expect(AppDataSource.fromString('nonsense').isMock, isTrue);
    expect(AppDataSource.fromString('').isMock, isTrue);
  });
}
