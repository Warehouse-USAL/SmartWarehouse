import 'package:auth/auth.dart';

class OnLogoutUseCase {
  static void call() {
    AuthFeatureBuilder.logout();
  }
}
