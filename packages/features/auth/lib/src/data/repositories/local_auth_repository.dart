import 'dart:developer';

import 'package:auth/src/data/models/persistable_auth_data.dart';
import 'package:auth/src/data/models/refresh_token_model.dart';
import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:auth/src/domain/repositories/auth_repository.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository({required this.httpHelper, required this.persistenceHelper});

  final HttpHelper httpHelper;
  static const _authKey = 'smart-warehouse-auth-key';
  final PersistenceHelper persistenceHelper;

  @override
  Future<Either<AuthFailure, AuthData?>> load() async {
    try {
      if (!await persistenceHelper.exists(_authKey)) {
        return const Right(null);
      }
      final result = await persistenceHelper.get(_authKey, PersistableAuthData.fromJson);
      return result.fold(
        (failure) => Left(AuthFailure()),
        (data) {
          final token = data.authData.token;
          if (token.isEmpty) return const Right(null);
          return Right(data.authData);
        },
      );
    } catch (e) {
      log('LocalAuthRepository.load error: $e');
      return Left(AuthFailure());
    }
  }

  @override
  Future<Either<AuthFailure, AuthData?>> refresh({String? refreshToken}) async {
    try {
      if (refreshToken == null) return await _onRefreshFailure();
      final result = await httpHelper.post(
        '/authenticate/refresh-session',
        data: {'refreshToken': refreshToken},
      );
      return result.fold(
        (failure) => _onRemoveToken(),
        (success) async {
          final data = success.data;
          final model = RefreshTokenModel.fromJson(data['data']);
          final authData = AuthData(token: model.token, refreshToken: model.refreshToken);
          final saveResult = await save(authData);
          return saveResult.fold(
            () => Right(authData),
            (failure) async => await _onRefreshFailure(),
          );
        },
      );
    } catch (e) {
      log('$e');
      return await _onRefreshFailure();
    }
  }

  Future<Either<AuthFailure, AuthData?>> _onRefreshFailure() async {
    await _onRemoveToken();
    return right(null);
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
