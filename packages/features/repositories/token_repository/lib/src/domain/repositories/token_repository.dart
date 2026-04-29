import 'package:dartz/dartz.dart';
import 'package:token_repository/src/data/models/token_model.dart';

export 'package:token_repository/src/data/models/token_model.dart';

abstract class TokenRepository {
  Future<Either<TokenFailure, TokenModel?>> fetch();
}

class TokenFailure {}
