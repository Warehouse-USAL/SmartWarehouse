import 'package:auth/src/domain/entities/auth_data.dart';

/// Construye un [AuthData] con defaults razonables.
///
/// Vive acá y no en `test_support` porque `AuthData` lo usa solo este package:
/// centralizarlo obligaría a `test_support` a depender de `auth`.
AuthData anAuthData({
  String token = 'token-de-prueba',
  String? refreshToken = 'refresh-de-prueba',
}) =>
    AuthData(token: token, refreshToken: refreshToken);
