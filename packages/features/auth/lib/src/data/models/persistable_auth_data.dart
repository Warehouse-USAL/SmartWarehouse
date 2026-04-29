import 'package:auth/src/domain/entities/auth_data.dart';
import 'package:commons/commons.dart';

class PersistableAuthData implements PersistableObject {
  PersistableAuthData({required this.authData});

  factory PersistableAuthData.fromJson(Map<String, dynamic> json) {
    return PersistableAuthData(
      authData: AuthData(
        token: json['token'],
        refreshToken: json['refreshToken'],
      ),
    );
  }

  final AuthData authData;

  @override
  Map<String, dynamic> toJson() {
    return {
      'token': authData.token,
      'refreshToken': authData.refreshToken,
    };
  }
}
