import 'dart:convert';
import 'dart:developer';

import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:auth/src/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepository) : super(const AuthState.empty());

  final AuthRepository authRepository;

  Future<void> load() async {
    await Future.delayed(const Duration(seconds: 1));
    final result = await authRepository.load();
    result.fold(
      (failure) => emit(const AuthState.empty()),
      (data) => emit(
        data == null ? const AuthState.empty() : AuthState.data(data, hasUpdated: false),
      ),
    );
  }

  Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp);
    } catch (e) {
      log('$e');
      return null;
    }
  }

  Future<void> save({required String token, String? refreshToken, bool hasUpdated = false}) async {
    final authData = AuthData(token: token, refreshToken: refreshToken);
    final result = await authRepository.save(authData);
    result.fold(
      () => emit(AuthState.data(authData, hasUpdated: hasUpdated)),
      (failure) => emit(const AuthState.empty()),
    );
  }

  Future<bool> reset() async {
    await authRepository.save(AuthData(token: '', refreshToken: ''));
    final result = await authRepository.remove();
    return result.fold(
      () {
        emit(const AuthState.empty());
        return true;
      },
      (failure) => false,
    );
  }

  /// Devuelve `true` si el access token se renovó correctamente; `false` si
  /// no se pudo refrescar (en cuyo caso el caller debe propagar el 401
  /// original al usuario sin reintentar — sino se produce un loop).
  Future<bool> _refreshToken() async {
    final result = await state.whenOrNull(
      data: (data, _) async {
        // Si el backend no nos dio refresh token (ej. el contrato actual de
        // /auth/login no expone uno), no podemos refrescar — pero tampoco
        // queremos hacer logout ante cualquier 401 transitorio. Dejamos el
        // state como está y devolvemos false para que el caller no reintente.
        final refreshToken = data.refreshToken;
        if (refreshToken == null || refreshToken.isEmpty) return false;

        final refreshResult = await authRepository.refresh(refreshToken: refreshToken);
        return refreshResult.fold(
          (failure) {
            load();
            return false;
          },
          (refreshed) {
            if (refreshed == null) {
              emit(const AuthState.empty());
              return false;
            }
            emit(AuthState.data(refreshed, hasUpdated: true));
            return true;
          },
        );
      },
    );
    return result ?? false;
  }

  Future<bool>? _refreshingFuture;

  Future<bool> onRefreshToken() async {
    _refreshingFuture ??= _refreshToken();
    final success = await _refreshingFuture!;
    _refreshingFuture = null;
    return success;
  }

  /// Returns true if the token is expired and the user should be forced to refresh it.
  bool isExpiredToken(int errorStatusCode, String? message) {
    return errorStatusCode == 401;
  }
}
