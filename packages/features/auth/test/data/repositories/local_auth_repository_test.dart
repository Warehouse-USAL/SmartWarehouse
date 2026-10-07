import 'package:auth/src/data/models/persistable_auth_data.dart';
import 'package:auth/src/data/repositories/local_auth_repository.dart';
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

import '../../support/auth_builders.dart';

class _FakePersistableAuthData extends Fake implements PersistableObject {}

void main() {
  late MockPersistenceHelper persistence;
  late MockHttpHelper http;
  late LocalAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakePersistableAuthData());
  });

  setUp(() {
    persistence = MockPersistenceHelper();
    http = MockHttpHelper();
    repo = LocalAuthRepository(httpHelper: http, persistenceHelper: persistence);
  });

  group('load', () {
    test('returns Right(null) when nothing is persisted', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => false);

      final result = await repo.load();

      expect(result, const Right<AuthFailure, AuthData?>(null));
      verifyNever(() => persistence.get<PersistableAuthData>(any(), any()));
    });

    test('returns the persisted auth data', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Right(
          PersistableAuthData(token: 'tok', refreshToken: 'ref'),
        ),
      );

      final result = await repo.load();

      final data = result.getOrElse(() => null);
      expect(data?.token, 'tok');
      expect(data?.refreshToken, 'ref');
    });

    test('treats a persisted empty token as no session', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Right(PersistableAuthData(token: '')),
      );

      final result = await repo.load();

      expect(result.getOrElse(() => anAuthData()), isNull);
    });

    test('returns a failure when persistence fails', () async {
      when(() => persistence.exists(any())).thenAnswer((_) async => true);
      when(() => persistence.get<PersistableAuthData>(any(), any())).thenAnswer(
        (_) async => const Left(PersistenceFailure.notFound()),
      );

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });

    test('returns a failure when persistence throws', () async {
      when(() => persistence.exists(any())).thenThrow(Exception('boom'));

      final result = await repo.load();

      expect(result.isLeft(), isTrue);
    });
  });

  group('save', () {
    test('returns None when persistence succeeds', () async {
      when(() => persistence.set(any(), any()))
          .thenAnswer((_) async => const None());

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
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());

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
    test('removes the token and returns Right(null) with no refresh token', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());

      final result = await repo.refresh();

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
      verifyNever(() => http.post(any(), data: any(named: 'data')));
    });

    test('removes the token when the refresh request fails', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());
      when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Left(
          HttpResponseError(errorType: 'http', message: 'unauthorized', statusCode: 401),
        ),
      );

      final result = await repo.refresh(refreshToken: 'ref-viejo');

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
    });

    test('removes the token and returns Right(null) when the response body has an unexpected shape', () async {
      when(() => persistence.remove(any()))
          .thenAnswer((_) async => const None());
      when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Right(HttpResponse<dynamic>(data: 'no es un mapa', status: '200')),
      );

      final result = await repo.refresh(refreshToken: 'ref');

      expect(result.getOrElse(() => anAuthData()), isNull);
      verify(() => persistence.remove(any())).called(1);
    });

    test('on success saves and returns the new AuthData', () async {
      when(() => persistence.set(any(), any()))
          .thenAnswer((_) async => const None());
      when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Right(
          HttpResponse<dynamic>(
            data: {
              'data': {'accessToken': 'nuevo-token', 'refreshToken': 'nuevo-refresh'},
            },
            status: '200',
          ),
        ),
      );

      final result = await repo.refresh(refreshToken: 'ref-viejo');

      final data = result.getOrElse(() => null);
      expect(data?.token, 'nuevo-token');
      expect(data?.refreshToken, 'nuevo-refresh');
      verify(() => persistence.set(any(), any())).called(1);
    });
  });
}
