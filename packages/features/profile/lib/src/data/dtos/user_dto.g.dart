// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  role: json['role'] as String,
  active: json['active'] as bool? ?? true,
  createdAt: json['created_at'] as String?,
  address: json['address'] == null
      ? null
      : AddressDto.fromJson(json['address'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'role': instance.role,
  'active': instance.active,
  'created_at': instance.createdAt,
  'address': instance.address?.toJson(),
};

_AddressDto _$AddressDtoFromJson(Map<String, dynamic> json) => _AddressDto(
  street: json['street'] as String?,
  department: json['department'] as String?,
  floor: json['floor'] as String?,
  postalCode: json['postal_code'] as String?,
);

Map<String, dynamic> _$AddressDtoToJson(_AddressDto instance) =>
    <String, dynamic>{
      'street': instance.street,
      'department': instance.department,
      'floor': instance.floor,
      'postal_code': instance.postalCode,
    };
