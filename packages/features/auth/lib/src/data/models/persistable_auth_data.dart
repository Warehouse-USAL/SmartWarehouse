import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:commons/commons.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'persistable_auth_data.freezed.dart';
part 'persistable_auth_data.g.dart';

/// Modelo persistido en Hive (clave `smart-warehouse-auth-key`). El JSON guardado
/// usa las keys `token` y `refreshToken` (camelCase), distinto del wire format
/// del backend (que es snake_case). Se mantiene así por compat con datos ya
/// persistidos en devices.
@freezed
sealed class PersistableAuthData
    with _$PersistableAuthData
    implements PersistableObject {
  const PersistableAuthData._();

  const factory PersistableAuthData({
    @Default('') String token,
    String? refreshToken,
  }) = _PersistableAuthData;

  factory PersistableAuthData.fromAuthData(AuthData data) => PersistableAuthData(
        token: data.token,
        refreshToken: data.refreshToken,
      );

  factory PersistableAuthData.fromJson(Map<String, dynamic> json) =>
      _$PersistableAuthDataFromJson(json);

  AuthData get authData => AuthData(token: token, refreshToken: refreshToken);
}
