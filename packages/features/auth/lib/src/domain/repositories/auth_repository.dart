import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Option<AuthFailure>> save(AuthData authData);

  Future<Either<AuthFailure, AuthData?>> load();

  Future<Option<AuthFailure>> remove();

  Future<Either<AuthFailure, AuthData?>> refresh({String? refreshToken});
}

class AuthFailure {}
