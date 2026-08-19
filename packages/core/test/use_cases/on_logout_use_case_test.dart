import 'package:auth/auth.dart';
import 'package:core/src/use_cases/session/on_logout_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  setUp(resetInjector);

  test('resets the session', () {
    final cubit = _MockAuthCubit();
    when(() => cubit.reset()).thenAnswer((_) async => true);
    registerMock<AuthCubit>(cubit);

    OnLogoutUseCase.call();

    verify(() => cubit.reset()).called(1);
  });
}
