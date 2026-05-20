import 'dart:async';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/domain/entities/login_credentials.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/entities/user.dart';
import 'package:login/src/domain/repositories/login_repository.dart';

/// Talks to `POST /auth/login`. Contrato:
/// `{ token, user: { id, name, email, role } }`.
class RemoteLoginRepository implements LoginRepository {
  RemoteLoginRepository({required this.httpHelper});

  final HttpHelper httpHelper;
  Completer<void>? _loginCompleter;

  @override
  Future<Either<LoginFailure, AuthTokens>> login(LoginCredentials credentials) async {
    try {
      final result = await httpHelper.post(
        '/auth/login',
        data: {
          'email': credentials.email.toLowerCase(),
          'password': credentials.password,
        },
        retryOnTokenExpired: false,
      );
      return result.fold(
        (error) => Left(_mapError(error)),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) return const Left(UnknownLoginFailure());
          final token = data['token'] as String?;
          if (token == null || token.isEmpty) return const Left(UnknownLoginFailure());
          return Right(AuthTokens(
            accessToken: token,
            user: _parseUser(data['user']),
          ));
        },
      );
    } catch (e, st) {
      log('login error', error: e, stackTrace: st);
      return const Left(UnknownLoginFailure());
    }
  }

  User? _parseUser(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    return User(
      id: (raw['id'] as String?) ?? '',
      name: (raw['name'] as String?) ?? '',
      email: (raw['email'] as String?) ?? '',
      role: (raw['role'] as String?) ?? '',
    );
  }

  LoginFailure _mapError(HttpResponseError error) {
    if (error.statusCode == 401) return const InvalidCredentialsFailure();
    final type = error.errorType?.toLowerCase() ?? '';
    if (type.contains('timeout')) return const TimeoutFailure();
    if (error.statusCode == 999) return const NetworkFailure();
    return UnknownLoginFailure(error.message ?? 'Ocurrió un error. Reintentá.');
  }

  @override
  Future<Option<LoginFailure>> authenticateEmail(String email) async {
    try {
      if (_loginCompleter != null) {
        return const Some(UnknownLoginFailure('Esperá a que termine el envío anterior.'));
      }
      _loginCompleter = Completer<void>();
      _loginCompleter?.future.whenComplete(() => _loginCompleter = null);
      final result = await httpHelper.post('/authenticate/email', data: {'email': email.toLowerCase()});
      await _completeAndWaitForCompleter();
      return result.fold(
        (failure) => Some(_mapError(failure)),
        (_) => const None(),
      );
    } catch (e) {
      log('$e');
      await _completeAndWaitForCompleter();
      return const Some(UnknownLoginFailure());
    }
  }

  Future<void> _completeAndWaitForCompleter() async {
    _loginCompleter?.complete();
    await _loginCompleter?.future;
  }
}
