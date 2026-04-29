import 'package:auth/auth.dart';
import 'package:flutter/cupertino.dart';

class OnLoginUseCase {
  static void call(
    BuildContext context, {
    required String token,
    String? refreshToken,
    bool hasUpdate = false,
  }) {
    hasUpdate
        ? AuthFeatureBuilder.update(token: token, refreshToken: refreshToken)
        : AuthFeatureBuilder.login(token: token, refreshToken: refreshToken);
  }
}
