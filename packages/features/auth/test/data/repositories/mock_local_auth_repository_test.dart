import 'dart:convert';

import 'package:auth/src/data/models/persistable_auth_data.dart';
import 'package:auth/src/data/repositories/mock_local_auth_repository.dart';
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

import '../../support/auth_builders.dart';

class _FakePersistableAuthData extends Fake implements PersistableObject {}

/// Arma un JWT falso (header.payload.signature) para que
/// `MockLocalAuthRepository.load()` pueda decodificar el claim
/// `isRegistered` del payload, tal como hace la implementación real.
String _fakeJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode(json.encode({'alg': 'none'})));
  final body = base64Url.encode(utf8.encode(json.encode(payload)));
  return '$header.$body.signature';
}

void main() {
  late MockPersistenceHelper persistence;
  late MockLocalAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakePersistableAuthData());
  });

  setUp(() {
    persistence = MockPersistenceHelper();
    repo = MockLocalAuthRepository(
      refreshTokenUrl: 'https://example.test/refresh',
      isAuthenticated: false,
      refreshTokenWillSucceed: true,
      persistenceHelper: persistence,
    );
  });

  group('load', () {
    test('returns Right(null) when nothing is persisted', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => false);

      final result = await repo.load();

      expect(result, const Right<AuthFailure, AuthData?>(null));
      verifyNever(() => persistence.get<PersistableAuthData>(any(), any()));
    });

    test('returns the auth data when the token payload marks the account as registered', () async {
      final token = _fakeJwt({'isRegistered': true});
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => Right(PersistableAuthData(token: token, refreshToken: 'ref')),
      );

      final result = await repo.load();

      final data = result.getOrElse(() => null);
      expect(data?.token, token);
      expect(data?.refreshToken, 'ref');
    });

    test('returns Right(null) when the token payload does not mark the account as registered', () async {
      final token = _fakeJwt({'isRegistered': false});
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => Right(PersistableAuthData(token: token)),
      );

      final result = await repo.load();

      expect(result.getOrElse(() => anAuthData()), isNull);
    });

    test('returns Right(null) when the token has no isRegistered claim', () async {
      final token = _fakeJwt({'sub': 'user-1'});
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => Right(PersistableAuthData(token: token)),
      );

      final result = await repo.load();

      expect(result.getOrElse(() => anAuthData()), isNull);
    });

    test('returns Right(null) when the token is malformed', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Right(PersistableAuthData(token: 'not-a-jwt')),
      );

      final result = await repo.load();

      expect(result.getOrElse(() => anAuthData()), isNull);
    });

    test('returns Left(AuthFailure) when persistence.get fails', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Left(PersistenceFailure.notFound()),
      );

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });

    test('returns Left(AuthFailure) when persistence throws', () async {
      when(() => persistence.exists(any())).thenThrow(Exception('boom'));

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });
  });

  group('save', () {
    test('returns None when persistence succeeds', () async {
      when(() => persistence.set(any(), any())).thenAnswer((_) async => const None());

      final result = await repo.save(anAuthData());

      expect(result.isNone(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence fails', () async {
      when(() => persistence.set(any(), any())).thenAnswer(
        (_) async => const Some(PersistenceFailure.other('disco lleno')),
      );

      final result = await repo.save(anAuthData());

      expect(result.isSome(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence throws', () async {
      when(() => persistence.set(any(), any())).thenThrow(Exception('boom'));

      final result = await repo.save(anAuthData());

      expect(result.isSome(), isTrue);
    });
  });

  group('remove', () {
    test('returns None when persistence succeeds', () async {
      when(() => persistence.remove(any())).thenAnswer((_) async => const None());

      final result = await repo.remove();

      expect(result.isNone(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence fails', () async {
      when(() => persistence.remove(any())).thenAnswer(
        (_) async => const Some(PersistenceFailure.notFound()),
      );

      final result = await repo.remove();

      expect(result.isSome(), isTrue);
    });

    test('returns Some(AuthFailure) when persistence throws', () async {
      when(() => persistence.remove(any())).thenThrow(Exception('boom'));

      final result = await repo.remove();

      expect(result.isSome(), isTrue);
    });
  });

  group('refresh', () {
    // DEFECTO REAL: `refresh()` hace `final body = result.body as Map<String,
    // dynamic>;`, pero `http.Response.body` siempre es un `String` (el JSON
    // crudo, sin decodificar). Ese cast falla en tiempo de ejecución sin
    // importar qué devuelva el servidor, cae siempre al `catch`, borra la
    // sesión y devuelve `Right(null)` — nunca puede tener éxito tal como está
    // escrito. Debería ser `json.decode(result.body)`. No se corrige acá
    // porque está fuera del alcance de este batch (y la clase no está
    // conectada a ningún feature builder), pero se deja pineado en el test
    // para que quede documentado y cualquier intento de "arreglarlo" note
    // que rompe esta expectativa.
    test(
      'removes the token and returns Right(null) even on a well-formed response, '
      'because the raw String body can never cast to Map (defecto real, ver comentario arriba)',
      () async {
        when(() => persistence.remove(any())).thenAnswer((_) async => const None());
        final client = MockClient((request) async {
          return http.Response(
            json.encode({'accessToken': 'nuevo-token', 'refreshToken': 'nuevo-refresh'}),
            200,
          );
        });

        final result = await http.runWithClient(
          () => repo.refresh(refreshToken: 'ref-viejo'),
          () => client,
        );

        expect(result.getOrElse(() => anAuthData()), isNull);
        verify(() => persistence.remove(any())).called(1);
      },
    );

    test('still returns Right(null) when removing the token after a failed refresh also fails', () async {
      when(() => persistence.remove(any())).thenAnswer(
        (_) async => const Some(PersistenceFailure.other('disco lleno')),
      );
      final client = MockClient((request) async => http.Response('{}', 200));

      final result = await http.runWithClient(
        () => repo.refresh(refreshToken: 'ref-viejo'),
        () => client,
      );

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
    });
  });
}
