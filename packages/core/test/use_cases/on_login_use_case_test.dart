import 'package:auth/auth.dart';
import 'package:core/src/use_cases/session/on_login_use_case.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_support/test_support.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUp(resetInjector);

  test('saves a fresh login when hasUpdate is false', () {
    final cubit = _MockAuthCubit();
    when(
      () => cubit.save(
        token: any(named: 'token'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    registerMock<AuthCubit>(cubit);

    OnLoginUseCase.call(
      _FakeBuildContext(),
      token: 'tok-1',
      refreshToken: 'ref-1',
    );

    verify(() => cubit.save(token: 'tok-1', refreshToken: 'ref-1')).called(1);
  });

  test('updates the existing session when hasUpdate is true', () {
    final cubit = _MockAuthCubit();
    when(
      () => cubit.save(
        token: any(named: 'token'),
        refreshToken: any(named: 'refreshToken'),
        hasUpdated: any(named: 'hasUpdated'),
      ),
    ).thenAnswer((_) async {});
    registerMock<AuthCubit>(cubit);

    OnLoginUseCase.call(
      _FakeBuildContext(),
      token: 'tok-2',
      refreshToken: 'ref-2',
      hasUpdate: true,
    );

    verify(
      () => cubit.save(token: 'tok-2', refreshToken: 'ref-2', hasUpdated: true),
    ).called(1);
  });
}
