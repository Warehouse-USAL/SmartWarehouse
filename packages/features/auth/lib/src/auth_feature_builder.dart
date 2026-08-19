import 'package:auth/src/data/repositories/local_auth_repository.dart';
import 'package:auth/src/data/repositories/mock_local_auth_repository.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'presentation/bloc/auth_cubit.dart';

class AuthFeatureBuilder {
  static AuthRepository _resolveRepository() {
    return Injector.i.resolve<AppDataSource>().isMock
        ? MockLocalAuthRepository(
            // El refresh del mock hace un POST real a esta URL; con un host
            // inexistente degrada limpio (borra el token y devuelve null),
            // que es el comportamiento esperado en modo mock.
            refreshTokenUrl: 'https://mock.invalid/refresh',
            isAuthenticated: false,
            refreshTokenWillSucceed: true,
            persistenceHelper: Injector.i.resolve<PersistenceHelper>(),
          )
        : LocalAuthRepository(
            persistenceHelper: Injector.i.resolve<PersistenceHelper>(),
            httpHelper: Injector.i.resolve<HttpHelper>(),
          );
  }

  static void injectDependencies() {
    final cubit = AuthCubit(_resolveRepository())..load();
    Injector.i.registerSingleton<AuthCubit>(cubit);
  }


  static void logout() => _resolve().reset();

  static AuthCubit _resolve() => Injector.i.resolve<AuthCubit>();

  static Future<void> login({required String token, String? refreshToken}) async {
    await _resolve().save(token: token, refreshToken: refreshToken);
  }

  static Future<void> update({required String token, String? refreshToken}) async {
    await _resolve().save(token: token, refreshToken: refreshToken, hasUpdated: true);
  }

  static Widget listenerWrapper({
    required Widget child,
    required VoidCallback onUserAuthenticated,
    required VoidCallback onUserLoggedOut,
  }) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: _resolve(),
      listener: (context, state) {
        state.whenOrNull(
          data: (data, hasUpdate) => hasUpdate ? null : onUserAuthenticated(),
          empty: () => onUserLoggedOut(),
        );
      },
      child: child,
    );
  }

  static AuthData? getAuthData() {
    final state = _resolve().state;
    return state.whenOrNull(data: (data, isRefreshToken) => data);
  }

  // returns if the token was refreshed
  static Future<bool> refreshToken() => _resolve().onRefreshToken();

  static bool isExpiredToken(int statusCode, String? message) {
    return _resolve().isExpiredToken(statusCode, message);
  }
}
