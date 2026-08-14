import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/auth_builders.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(AuthData.empty());
  });

  setUp(() {
    repo = _MockAuthRepository();
    when(() => repo.save(any())).thenAnswer((_) async => const None());
  });

  /// Deja el cubit en estado `data` sin pasar por `load()`, que tiene un
  /// delay de un segundo hardcodeado en producción.
  Future<AuthCubit> cubitWithSession({String? refreshToken}) async {
    final cubit = AuthCubit(repo);
    await cubit.save(token: 'tok-viejo', refreshToken: refreshToken);
    return cubit;
  }

  test('returns false when there is no session', () async {
    final cubit = AuthCubit(repo);

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns false when the session has no refresh token', () async {
    final cubit = await cubitWithSession(refreshToken: null);

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns false when the refresh token is empty', () async {
    final cubit = await cubitWithSession(refreshToken: '');

    expect(await cubit.onRefreshToken(), isFalse);
    verifyNever(() => repo.refresh(refreshToken: any(named: 'refreshToken')));
    await cubit.close();
  });

  test('returns true and emits the renewed session on success', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async => Right(anAuthData(token: 'tok-nuevo', refreshToken: 'ref-nuevo')),
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final ok = await cubit.onRefreshToken();

    expect(ok, isTrue);
    expect(cubit.state.whenOrNull(data: (d, _) => d.token), 'tok-nuevo');
    expect(cubit.state.whenOrNull(data: (_, updated) => updated), isTrue);
    await cubit.close();
  });

  test('returns false and empties the session when refresh yields nothing', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async => const Right(null));
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final ok = await cubit.onRefreshToken();

    expect(ok, isFalse);
    expect(cubit.state, const AuthState.empty());
    await cubit.close();
  });

  test('returns false when the repository fails', () async {
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async => Left(AuthFailure()));
    when(() => repo.load()).thenAnswer((_) async => const Right(null));
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    expect(await cubit.onRefreshToken(), isFalse);
    await cubit.close();
  });

  test('two concurrent callers share a single refresh call', () async {
    var calls = 0;
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return Right(anAuthData(token: 'tok-nuevo', refreshToken: 'ref-nuevo'));
      },
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    final results = await Future.wait([
      cubit.onRefreshToken(),
      cubit.onRefreshToken(),
    ]);

    expect(results, [true, true]);
    expect(calls, 1, reason: 'el de-dup de _refreshingFuture debe evitar la estampida');
    await cubit.close();
  });

  test('a later refresh runs again after the first one settles', () async {
    var calls = 0;
    when(() => repo.refresh(refreshToken: any(named: 'refreshToken'))).thenAnswer(
      (_) async {
        calls++;
        return Right(anAuthData(token: 'tok-$calls', refreshToken: 'ref-$calls'));
      },
    );
    final cubit = await cubitWithSession(refreshToken: 'ref-viejo');

    await cubit.onRefreshToken();
    await cubit.onRefreshToken();

    expect(calls, 2, reason: '_refreshingFuture se limpia al terminar');
    await cubit.close();
  });
}
