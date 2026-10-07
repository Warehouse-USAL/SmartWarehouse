import 'package:auth/src/domain/entities/auth_data.dart';

/// Construye un [AuthData] con defaults razonables.
///
/// Vive acá y no en un package compartido porque `AuthData` lo usa solo este
/// package. La regla está en el spec §4.3: un builder se comparte solo si lo
/// necesitan dos o más packages, y `test_support` nunca depende de una feature.
AuthData anAuthData({
  String token = 'token-de-prueba',
  String? refreshToken = 'refresh-de-prueba',
}) =>
    AuthData(token: token, refreshToken: refreshToken);
