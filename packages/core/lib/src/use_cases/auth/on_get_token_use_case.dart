import 'package:auth/auth.dart';

class OnGetTokenUseCase {
  static String? call() => AuthFeatureBuilder.getAuthData()?.token;
}
