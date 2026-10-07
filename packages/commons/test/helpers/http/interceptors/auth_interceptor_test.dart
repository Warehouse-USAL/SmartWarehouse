import 'package:commons/helpers/http/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaces request headers with the interceptor result', () {
    final interceptor = AuthInterceptor(
      requestInterceptionData: (headers) => {
        ...headers,
        'Authorization': 'Bearer token-123',
      },
    );
    final options = RequestOptions(path: '/products', headers: {'Accept': 'json'});

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(options.headers['Authorization'], 'Bearer token-123');
    expect(options.headers['Accept'], 'json');
  });

  test('passes the existing headers into the callback', () {
    Map<String, dynamic>? seen;
    final interceptor = AuthInterceptor(
      requestInterceptionData: (headers) {
        seen = headers;
        return headers;
      },
    );
    final options = RequestOptions(path: '/x', headers: {'A': '1'});

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(seen, containsPair('A', '1'));
  });
}
