import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

import 'support/auth_builders.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

/// `AuthCubit.load()` tiene un `Future.delayed(Duration(seconds: 1))`
/// hardcodeado en producción; hay que esperarlo de verdad tras
/// `injectDependencies()`.
const _loadWait = Duration(milliseconds: 1200);

void main() {
  setUp(() => resetInjector());

  group('injectDependencies', () {
    test('wires an AuthCubit from the injector and registers it as a singleton', () async {
      final persistence = registerMock<PersistenceHelper>(MockPersistenceHelper());
      registerMock<HttpHelper>(MockHttpHelper());
      // Desde #174 el builder elige el repositorio según AppDataSource.
      Injector.i.registerSingleton<AppDataSource>(const AppDataSource.remote());
      when(() => persistence.exists(any())).thenAnswer((_) async => false);

      AuthFeatureBuilder.injectDependencies();

      expect(Injector.i.isRegistered<AuthCubit>(), isTrue);
      final registered = Injector.i.resolve<AuthCubit>();
      await Future<void>.delayed(_loadWait);
      expect(registered.state, const AuthState.empty());
      await registered.close();
    });
  });

  group('with a resolved cubit', () {
    late _MockAuthCubit cubit;

    setUp(() {
      cubit = _MockAuthCubit();
      registerMock<AuthCubit>(cubit);
    });

    test('logout resets the resolved cubit', () async {
      when(() => cubit.reset()).thenAnswer((_) async => true);

      AuthFeatureBuilder.logout();

      verify(() => cubit.reset()).called(1);
    });

    test('login saves the new session without marking it as updated', () async {
      when(
        () => cubit.save(
          token: any(named: 'token'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});

      await AuthFeatureBuilder.login(token: 'tok', refreshToken: 'ref');

      verify(() => cubit.save(token: 'tok', refreshToken: 'ref')).called(1);
    });

    test('update saves the new session and marks it as updated', () async {
      when(
        () => cubit.save(
          token: any(named: 'token'),
          refreshToken: any(named: 'refreshToken'),
          hasUpdated: any(named: 'hasUpdated'),
        ),
      ).thenAnswer((_) async {});

      await AuthFeatureBuilder.update(token: 'tok2', refreshToken: 'ref2');

      verify(() => cubit.save(token: 'tok2', refreshToken: 'ref2', hasUpdated: true)).called(1);
    });

    test('getAuthData returns the auth data from a data state', () {
      final data = anAuthData(token: 'tok');
      when(() => cubit.state).thenReturn(AuthState.data(data, hasUpdated: false));

      expect(AuthFeatureBuilder.getAuthData(), data);
    });

    test('getAuthData returns null from an empty state', () {
      when(() => cubit.state).thenReturn(const AuthState.empty());

      expect(AuthFeatureBuilder.getAuthData(), isNull);
    });

    test('refreshToken delegates to the cubit', () async {
      when(() => cubit.onRefreshToken()).thenAnswer((_) async => true);

      final result = await AuthFeatureBuilder.refreshToken();

      expect(result, isTrue);
      verify(() => cubit.onRefreshToken()).called(1);
    });

    test('isExpiredToken delegates to the cubit', () {
      when(() => cubit.isExpiredToken(401, 'msg')).thenReturn(true);

      expect(AuthFeatureBuilder.isExpiredToken(401, 'msg'), isTrue);
    });

    group('listenerWrapper', () {
      testWidgets('calls onUserAuthenticated when a fresh session is emitted', (tester) async {
        final controller = StreamController<AuthState>();
        addTearDown(controller.close);
        whenListen(cubit, controller.stream, initialState: const AuthState.empty());
        var authenticatedCalls = 0;
        var loggedOutCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: AuthFeatureBuilder.listenerWrapper(
              onUserAuthenticated: () => authenticatedCalls++,
              onUserLoggedOut: () => loggedOutCalls++,
              child: const SizedBox.shrink(),
            ),
          ),
        );

        controller.add(AuthState.data(anAuthData(), hasUpdated: false));
        await tester.pump();

        expect(authenticatedCalls, 1);
        expect(loggedOutCalls, 0);
      });

      testWidgets('does nothing when the emitted session is only a token update', (tester) async {
        final controller = StreamController<AuthState>();
        addTearDown(controller.close);
        whenListen(cubit, controller.stream, initialState: const AuthState.empty());
        var authenticatedCalls = 0;
        var loggedOutCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: AuthFeatureBuilder.listenerWrapper(
              onUserAuthenticated: () => authenticatedCalls++,
              onUserLoggedOut: () => loggedOutCalls++,
              child: const SizedBox.shrink(),
            ),
          ),
        );

        controller.add(AuthState.data(anAuthData(), hasUpdated: true));
        await tester.pump();

        expect(authenticatedCalls, 0);
        expect(loggedOutCalls, 0);
      });

      testWidgets('calls onUserLoggedOut when the session becomes empty', (tester) async {
        final controller = StreamController<AuthState>();
        addTearDown(controller.close);
        whenListen(
          cubit,
          controller.stream,
          initialState: AuthState.data(anAuthData(), hasUpdated: false),
        );
        var authenticatedCalls = 0;
        var loggedOutCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: AuthFeatureBuilder.listenerWrapper(
              onUserAuthenticated: () => authenticatedCalls++,
              onUserLoggedOut: () => loggedOutCalls++,
              child: const SizedBox.shrink(),
            ),
          ),
        );

        controller.add(const AuthState.empty());
        await tester.pump();

        expect(loggedOutCalls, 1);
        expect(authenticatedCalls, 0);
      });
    });
  });
}
