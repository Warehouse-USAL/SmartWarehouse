import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/auth_builders.dart';

void main() {
  test('empty has a blank token and a blank refresh token', () {
    final data = AuthData.empty();

    expect(data.token, '');
    expect(data.refreshToken, '');
  });

  test('two instances with the same fields are equal', () {
    expect(
      anAuthData(token: 't', refreshToken: 'r'),
      anAuthData(token: 't', refreshToken: 'r'),
    );
  });

  test('a different token makes them unequal', () {
    expect(
      anAuthData(token: 'a'),
      isNot(anAuthData(token: 'b')),
    );
  });

  test('a different refresh token makes them unequal', () {
    expect(
      anAuthData(token: 't', refreshToken: 'a'),
      isNot(anAuthData(token: 't', refreshToken: 'b')),
    );
  });

  test('equal instances share a hashCode', () {
    expect(
      anAuthData(token: 't', refreshToken: 'r').hashCode,
      anAuthData(token: 't', refreshToken: 'r').hashCode,
    );
  });

  test('refreshToken may be null', () {
    expect(anAuthData(refreshToken: null).refreshToken, isNull);
  });
}
