class AuthData {
  const AuthData({required this.token, this.refreshToken});

  factory AuthData.empty() => const AuthData(token: '', refreshToken: '');

  final String token;
  final String? refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthData &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode => Object.hash(token, refreshToken);
}
