import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:token_repository/token_repository.dart';

/// Builds a JWT-shaped string whose payload is [payload].
///
/// The signature is not verified by the repository, so any third segment works.
String _jwt(Map<String, dynamic> payload) {
  final encoded = base64Url.encode(utf8.encode(json.encode(payload)));
  return 'header.$encoded.signature';
}

void main() {
  test('returns Right(null) when there is no token', () async {
    final repo = LocalTokenRepository(onGetTokenUseCase: () => null);

    final result = await repo.fetch();

    expect(result, const Right<TokenFailure, TokenModel?>(null));
  });

  test('decodes the user object out of the payload', () async {
    final token = _jwt({
      'user': {
        'email': 'admin@smartwarehouse.local',
        'isRegistered': true,
        'agentId': 'agent-7',
      },
    });
    final repo = LocalTokenRepository(onGetTokenUseCase: () => token);

    final result = await repo.fetch();

    final model = result.getOrElse(() => null);
    expect(model?.email, 'admin@smartwarehouse.local');
    expect(model?.isRegistered, isTrue);
    expect(model?.agentId, 'agent-7');
  });

  test('agentId is optional', () async {
    final token = _jwt({
      'user': {'email': 'a@b.c', 'isRegistered': false},
    });
    final repo = LocalTokenRepository(onGetTokenUseCase: () => token);

    final result = await repo.fetch();

    expect(result.getOrElse(() => null)?.agentId, isNull);
  });

  test('returns a failure when the token does not have three segments', () async {
    final repo = LocalTokenRepository(onGetTokenUseCase: () => 'not-a-jwt');

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the payload is not valid base64', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => 'header.!!!not-base64!!!.signature',
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the payload has no user key', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => _jwt({'sub': '123'}),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the user object is missing required fields', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => _jwt({
        'user': {'email': 'a@b.c'},
      }),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });

  test('returns a failure when the callback throws', () async {
    final repo = LocalTokenRepository(
      onGetTokenUseCase: () => throw Exception('boom'),
    );

    final result = await repo.fetch();

    expect(result.isLeft(), isTrue);
  });
}
