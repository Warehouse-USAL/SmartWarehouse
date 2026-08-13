import 'package:auth/auth.dart';
import 'package:core/src/use_cases/interceptor/on_intercept_http_request_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  setUp(resetInjector);

  test('returns the headers untouched when there is no session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(const AuthState.empty());
    registerMock<AuthCubit>(cubit);

    final headers = OnInterceptHttpRequestUseCase.call({'Accept': 'json'});

    expect(headers, {'Accept': 'json'});
    expect(headers.containsKey('Authorization'), isFalse);
  });

  test('adds the Authorization header when there is a session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.state).thenReturn(
      const AuthState.data(
        AuthData(token: 'tok-123', refreshToken: 'ref-123'),
        hasUpdated: false,
      ),
    );
    registerMock<AuthCubit>(cubit);

    final headers = OnInterceptHttpRequestUseCase.call({'Accept': 'json'});

    expect(headers['Authorization'], 'Bearer tok-123');
    expect(headers['Accept'], 'json');
  });
}
