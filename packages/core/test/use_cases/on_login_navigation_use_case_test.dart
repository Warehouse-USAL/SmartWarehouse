import 'package:commons/commons.dart';
import 'package:core/src/use_cases/login/on_login_navigation_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login/login.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

void main() {
  setUp(resetInjector);

  testWidgets('navigates to the login page replacing the current route',
      (tester) async {
    final navigation = registerMock<NavigationHelper>(MockNavigationHelper());

    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    OnLoginNavigationUseCase.call(capturedContext);

    verify(
      () => navigation.pushNamed(
        capturedContext,
        routeName: LoginFeatureBuilder.path,
        replace: true,
      ),
    ).called(1);
  });
}
