import 'package:auth/src/data/repositories/local_auth_repository.dart';
import 'package:commons/commons.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'presentation/bloc/auth_cubit.dart';

class AuthFeatureBuilder {
  static void injectDependencies() {
    final cubit = AuthCubit(
      LocalAuthRepository(
        persistenceHelper: Injector.i.resolve<PersistenceHelper>(),
        httpHelper: Injector.i.resolve<HttpHelper>(),
      ),
    )..load();
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
