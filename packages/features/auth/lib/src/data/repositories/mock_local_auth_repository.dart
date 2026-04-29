import 'dart:convert';
import 'dart:developer';

import 'package:auth/src/data/models/persistable_auth_data.dart';
import 'package:auth/src/data/models/refresh_token_model.dart';
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:commons/helpers/persistence_helper/persistence_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

class MockLocalAuthRepository implements AuthRepository {
  MockLocalAuthRepository({
    required this.refreshTokenUrl,
    required this.isAuthenticated,
    required this.refreshTokenWillSucceed,
    required this.persistenceHelper,
  });

  final String refreshTokenUrl;
  final bool isAuthenticated, refreshTokenWillSucceed;
  final PersistenceHelper persistenceHelper;
  static const _authKey = 'smart-warehouse-auth-key';

  T? _decodeToken<T>({required String token, required String key}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(resp);
      if (map is! Map<String, dynamic>) throw Exception('invalid payload');
      return map[key] as T?;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  @override
  Future<Either<AuthFailure, AuthData?>> load() async {
    try {
      if (await persistenceHelper.exists(_authKey)) {
        final result = await persistenceHelper.get(_authKey, PersistableAuthData.fromJson);

        return result.fold(
          (failure) => Left(AuthFailure()),
          (data) {
            final isRegistered = _decodeToken<bool>(token: data.authData.token, key: 'isRegistered') ?? false;
            return isRegistered ? Right(data.authData) : const Right(null);
          },
        );
      } else {
        return const Right(null);
      }
    } catch (e) {
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthData?>> refresh({String? refreshToken}) async {
    // using http because we cant use dio here, because dio has the baseUrl
    try {
      final result = await http.post(
        Uri.parse(refreshTokenUrl),
        body: {'refreshToken': refreshToken},
      );
      final body = result.body as Map<String, dynamic>;
      final model = RefreshTokenModel.fromJson(body);
      final authData = AuthData(token: model.token, refreshToken: model.refreshToken);
      final saveResult = await save(authData);
      return saveResult.fold(
        () => Right(authData),
        (failure) => _onRemoveToken(),
      );
    } catch (e) {
      log('$e');
      await _onRemoveToken();
      return right(null);
    }
  }

  Future<Right<AuthFailure, AuthData?>> _onRemoveToken() async {
    await remove();
    return const Right(null);
  }

  @override
  Future<Option<AuthFailure>> remove() async {
    try {
      final result = await persistenceHelper.remove(_authKey);
      return result.fold(() => const None(), (_) => Some(AuthFailure()));
    } catch (e) {
      log('$e');
      return Some(AuthFailure());
    }
  }

  @override
  Future<Option<AuthFailure>> save(AuthData authData) async {
    try {
      final result = await persistenceHelper.set(_authKey, PersistableAuthData(authData: authData));
      return result.fold(() => const None(), (_) => Some(AuthFailure()));
    } catch (e) {
      return Some(AuthFailure());
    }
  }
}
