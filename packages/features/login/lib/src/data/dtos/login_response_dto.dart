import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:login/src/data/dtos/user_dto.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

@freezed
sealed class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String token,
    UserDto? user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}
