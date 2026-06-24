import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// Espejo de `UserResponse` del back (`GET /users/{id}` y `PATCH /users/me`).
///
/// ```json
/// {
///   "id": "6a20...", "email": "admin@...", "name": "System Admin",
///   "role": "SUPERADMIN", "active": true, "created_at": "...",
///   "address": {
///     "street": "Av. Siempre Viva 742",
///     "department": null, "floor": null,
///     "postal_code": "1414"
///   }
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
    AddressDto? address,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}

@freezed
sealed class AddressDto with _$AddressDto {
  const factory AddressDto({
    String? street,
    String? department,
    String? floor,
    String? postalCode,
  }) = _AddressDto;

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);
}
