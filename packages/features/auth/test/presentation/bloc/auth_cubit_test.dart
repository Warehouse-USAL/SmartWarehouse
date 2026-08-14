import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_cubit.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/auth_builders.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// `load()` tiene un `Future.delayed(Duration(seconds: 1))` hardcodeado en
/// producción, así que blocTest tiene que esperarlo de verdad.
const _loadWait = Duration(milliseconds: 1200);

void main() {
  late _MockAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(AuthData.empty());
  });

  setUp(() => repo = _MockAuthRepository());

  test('initial state is empty', () {
    final cubit = AuthCubit(repo);

    expect(cubit.state, const AuthState.empty());
    cubit.close();
  });

  group('load', () {
    blocTest<AuthCubit, AuthState>(
      'emits data when the repository returns a session',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => Right(anAuthData(token: 'tok'))),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [
        isA<AuthState>().having(
          (s) => s.whenOrNull(data: (d, _) => d.token),
          'token',
          'tok',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when the repository returns no session',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => const Right(null)),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [const AuthState.empty()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when the repository fails',
      setUp: () => when(() => repo.load())
          .thenAnswer((_) async => Left(AuthFailure())),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.load(),
      wait: _loadWait,
      expect: () => [const AuthState.empty()],
    );
  });

  group('save', () {
    blocTest<AuthCubit, AuthState>(
      'emits data with hasUpdated false by default',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => const None()),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo', refreshToken: 'ref'),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.whenOrNull(data: (d, _) => d.token), 'token', 'nuevo')
            .having((s) => s.whenOrNull(data: (_, u) => u), 'hasUpdated', false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'propagates hasUpdated true',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => const None()),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo', hasUpdated: true),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.whenOrNull(data: (_, u) => u), 'hasUpdated', true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits empty when saving fails',
      setUp: () => when(() => repo.save(any()))
          .thenAnswer((_) async => Some(AuthFailure())),
      build: () => AuthCubit(repo),
      act: (cubit) => cubit.save(token: 'nuevo'),
      expect: () => [const AuthState.empty()],
    );
  });

  group('reset', () {
    test('returns true and emits empty when removal succeeds', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => const None());
      final cubit = AuthCubit(repo);

      final ok = await cubit.reset();

      expect(ok, isTrue);
      expect(cubit.state, const AuthState.empty());
      await cubit.close();
    });

    test('returns false when removal fails', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => Some(AuthFailure()));
      final cubit = AuthCubit(repo);

      final ok = await cubit.reset();

      expect(ok, isFalse);
      await cubit.close();
    });

    test('blanks the stored session before removing it', () async {
      when(() => repo.save(any())).thenAnswer((_) async => const None());
      when(() => repo.remove()).thenAnswer((_) async => const None());
      final cubit = AuthCubit(repo);

      await cubit.reset();

      final saved = verify(() => repo.save(captureAny())).captured.single as AuthData;
      expect(saved.token, isEmpty);
      await cubit.close();
    });
  });
}
