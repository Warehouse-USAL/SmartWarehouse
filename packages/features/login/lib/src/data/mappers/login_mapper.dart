import 'package:login/src/data/dtos/login_response_dto.dart';
import 'package:login/src/data/dtos/user_dto.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/domain/entities/user.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  AuthTokens toEntity() => AuthTokens(
        accessToken: token,
        user: user?.toEntity(),
      );
}

extension UserDtoMapper on UserDto {
  User toEntity() => User(id: id, name: name, email: email, role: role);
}
