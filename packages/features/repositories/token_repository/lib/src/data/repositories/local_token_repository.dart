import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:token_repository/src/domain/repositories/token_repository.dart';

class LocalTokenRepository implements TokenRepository {
  LocalTokenRepository({required this.onGetTokenUseCase});

  final String? Function() onGetTokenUseCase;

  @override
  Future<Either<TokenFailure, TokenModel?>> fetch() async {
    try {
      final token = onGetTokenUseCase();
      if (token == null) return const Right(null);
      final userMap = _decodeToken(token);
      return Right(TokenModel.fromJson(userMap));
    } catch (e) {
      log('$e');
      return Left(TokenFailure());
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('invalid token');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final map = json.decode(resp);
    if (map is! Map<String, dynamic>) throw Exception('invalid payload');
    return map['user'];
  }
}
