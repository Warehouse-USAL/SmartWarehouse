import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// Espejo de `UserResponse` del back (`GET /users/{id}`).
///
/// ```json
/// {
///   "id": "6a20...", "email": "admin@...", "name": "System Admin",
///   "role": "SUPERADMIN", "active": true, "created_at": "2026-06-03T..."
/// }
/// ```
@freezed
sealed class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String name,
    required String role,
    @Default(true) bool active,
    String? createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}
