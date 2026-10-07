import 'package:commons/commons.dart';
import 'package:core/src/navigation/routes.dart';
import 'package:core/src/use_cases/session/on_user_authenticated_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

void main() {
  setUp(resetInjector);

  testWidgets('navigates to the catalog replacing the current route',
      (tester) async {
    // `pushNamed` returns void, so it needs no `when(...)` stub — mocktail
    // records the call and returns null on its own.
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

    OnUserAuthenticatedUseCase.call(capturedContext);

    verify(
      () => navigation.pushNamed(
        capturedContext,
        routeName: Routes.catalog,
        replace: true,
      ),
    ).called(1);
  });
}
