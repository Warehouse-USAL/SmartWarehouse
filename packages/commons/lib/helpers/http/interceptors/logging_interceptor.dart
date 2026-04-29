// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('*** Request ***');
    print('URI: ${options.uri}');
    print('Method: ${options.method}');
    print('Headers: ${options.headers}');
    if (options.data != null) print('Body: ${options.data}');
    print('****************');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('*** Response ***');
    print('Status Code: ${response.statusCode}');
    print('Data: ${response.data}');
    print('****************');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('*** Error ***');
    print('Error: ${err.error}');
    print('Message: ${err.message}');
    print('URI: ${err.requestOptions.uri}');
    if (err.response != null) {
      print('Status Code: ${err.response?.statusCode}');
      print('Data: ${err.response?.data}');
    }
    print('****************');
    super.onError(err, handler);
  }
}
