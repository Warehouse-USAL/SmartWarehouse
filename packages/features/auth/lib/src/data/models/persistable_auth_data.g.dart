// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistable_auth_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersistableAuthData _$PersistableAuthDataFromJson(Map<String, dynamic> json) =>
    _PersistableAuthData(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
    );

Map<String, dynamic> _$PersistableAuthDataToJson(
  _PersistableAuthData instance,
) => <String, dynamic>{
  'token': instance.token,
  'refreshToken': instance.refreshToken,
};
