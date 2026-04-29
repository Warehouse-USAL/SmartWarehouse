import 'package:auth/auth.dart';

class OnInterceptHttpRequestUseCase {
  static Map<String, dynamic> call(Map<String, dynamic> headers) {
    final token = AuthFeatureBuilder.getAuthData()?.token;
    if (token == null) return headers;
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }
}
