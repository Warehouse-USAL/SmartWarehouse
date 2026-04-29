class AuthData {
  AuthData({required this.token, this.refreshToken});

  factory AuthData.empty() => AuthData(token: '', refreshToken: '');

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
  int get hashCode => token.hashCode ^ refreshToken.hashCode;

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
