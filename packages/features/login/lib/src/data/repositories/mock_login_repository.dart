import 'package:dartz/dartz.dart';
import 'package:login/src/domain/entities/auth_tokens.dart';
import 'package:login/src/domain/entities/login_credentials.dart';
import 'package:login/src/domain/entities/login_failure.dart';
import 'package:login/src/domain/entities/user.dart';
import 'package:login/src/domain/repositories/login_repository.dart';

class MockLoginRepository implements LoginRepository {
  static const _email = 'ana.lopez@smartwarehouse.com';
  static const _password = 'Test1234';

  // JWT estructuralmente válido (header.payload.signature). Payload incluye
  // `user.isRegistered: true` para que LocalAuthRepository.load() lo acepte.
  static const _fakeJwt =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJ1c2VyIjp7ImlzUmVnaXN0ZXJlZCI6dHJ1ZSwiZW1haWwiOiJhbmEubG9wZXpAc21hcnR3YXJlaG91c2UuY29tIn19.'
      'mock-signature';

  static const _fakeRefresh = 'mock-refresh-token';

  static const _mockUser = User(
    id: 'u_8f2a',
    name: 'Ana López',
    email: _email,
    role: 'operator',
  );

  @override
  Future<Either<LoginFailure, AuthTokens>> login(LoginCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final emailMatches = credentials.email.toLowerCase() == _email;
    if (emailMatches && credentials.password == _password) {
      return const Right(AuthTokens(
        accessToken: _fakeJwt,
        refreshToken: _fakeRefresh,
        user: _mockUser,
      ));
    }
    return const Left(InvalidCredentialsFailure());
  }

  @override
  Future<Option<LoginFailure>> authenticateEmail(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return const None();
  }
}
