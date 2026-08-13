import 'package:auth/auth.dart';
import 'package:core/src/use_cases/auth/on_get_token_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  setUp(resetInjector);

  test('returns the token from the current session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(
      const AuthState.data(
        AuthData(token: 'tok-123', refreshToken: 'ref-123'),
        hasUpdated: false,
      ),
    );
    registerMock<AuthCubit>(cubit);

    final token = OnGetTokenUseCase.call();

    expect(token, 'tok-123');
  });

  test('returns null when there is no session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(const AuthState.empty());
    registerMock<AuthCubit>(cubit);

    final token = OnGetTokenUseCase.call();

    expect(token, isNull);
  });
}
