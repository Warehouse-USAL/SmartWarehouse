import 'dart:convert';

import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Arma un string con forma de JWT cuyo payload es [payload].
/// La firma no se valida, así que cualquier tercer segmento sirve.
String _jwt(Map<String, dynamic> payload) {
  final encoded = base64Url.encode(utf8.encode(json.encode(payload)));
  return 'header.$encoded.signature';
}

void main() {
  late AuthCubit cubit;

  setUp(() => cubit = AuthCubit(_MockAuthRepository()));
  tearDown(() => cubit.close());

  group('decodeToken', () {
    test('decodes the payload of a well-formed token', () {
      final decoded = cubit.decodeToken(_jwt({'sub': '123', 'role': 'admin'}));

      expect(decoded, {'sub': '123', 'role': 'admin'});
    });

    test('returns null when the token does not have three segments', () {
      expect(cubit.decodeToken('no-es-un-jwt'), isNull);
    });

    test('returns null when the payload is not valid base64', () {
      expect(cubit.decodeToken('header.!!!no-base64!!!.signature'), isNull);
    });

    test('returns null for an empty token', () {
      expect(cubit.decodeToken(''), isNull);
    });
  });

  group('isExpiredToken', () {
    test('is true for 401', () {
      expect(cubit.isExpiredToken(401, null), isTrue);
    });

    test('is false for any other status code', () {
      expect(cubit.isExpiredToken(200, null), isFalse);
      expect(cubit.isExpiredToken(403, null), isFalse);
      expect(cubit.isExpiredToken(500, 'server error'), isFalse);
    });
  });
}
