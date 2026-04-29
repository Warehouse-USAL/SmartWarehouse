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

  Future<void> _refreshToken() async {
    await state.whenOrNull(
      data: (data, _) async {
        final result = await authRepository.refresh(refreshToken: data.refreshToken);
        result.fold(
          (failure) => load(),
          (data) => emit(data == null ? const AuthState.empty() : AuthState.data(data, hasUpdated: true)),
        );
      },
    );
  }

  Future<void>? _refreshingFuture;

  Future<bool> onRefreshToken() async {
    _refreshingFuture ??= _refreshToken();
    await _refreshingFuture;
    _refreshingFuture = null;
    return state.whenOrNull(data: (data, _) => data) != null;
  }

  /// Returns true if the token is expired and the user should be forced to refresh it.
  bool isExpiredToken(int errorStatusCode, String? message) {
    return errorStatusCode == 401;
  }
}
