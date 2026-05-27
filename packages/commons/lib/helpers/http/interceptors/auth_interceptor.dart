import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.requestInterceptionData});

  final Map<String, dynamic> Function(Map<String, dynamic> header) requestInterceptionData;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers = requestInterceptionData(options.headers);
    super.onRequest(options, handler);
  }

}
