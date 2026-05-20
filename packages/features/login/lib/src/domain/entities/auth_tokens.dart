import 'package:login/src/domain/entities/user.dart';

/// Resultado del login. El contrato `POST /auth/login` devuelve
/// `{ token, user }`. No hay refresh token en este endpoint, pero se mantiene
/// el campo opcional por compatibilidad con flujos de sesión persistida.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final User? user;
}
