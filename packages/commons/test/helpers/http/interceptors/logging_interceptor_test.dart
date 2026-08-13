import 'dart:async';

import 'package:commons/helpers/http/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _capturePrints(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, line) => lines.add(line),
    ),
  );
  return lines;
}

void main() {
  final interceptor = LoggingInterceptor();

  test('onRequest logs the URI and the method', () {
    final options = RequestOptions(
      path: '/products',
      method: 'GET',
      baseUrl: 'https://api.example.com',
      headers: {'Accept': 'json'},
    );

    final lines = _capturePrints(() {
      interceptor.onRequest(options, RequestInterceptorHandler());
    });

    expect(lines.any((l) => l.contains('URI: ${options.uri}')), isTrue);
    expect(lines.any((l) => l.contains('Method: GET')), isTrue);
    expect(lines.any((l) => l.contains('Headers:') && l.contains('Accept')),
        isTrue);
  });

  test('onRequest logs the body only when data is present', () {
    final withoutBody = RequestOptions(path: '/x', method: 'GET');
    final linesWithoutBody = _capturePrints(() {
      interceptor.onRequest(withoutBody, RequestInterceptorHandler());
    });
    expect(linesWithoutBody.any((l) => l.startsWith('Body:')), isFalse);

    final withBody = RequestOptions(path: '/x', method: 'POST', data: {'a': 1});
    final linesWithBody = _capturePrints(() {
      interceptor.onRequest(withBody, RequestInterceptorHandler());
    });
    expect(linesWithBody.any((l) => l.contains('Body:') && l.contains('a')),
        isTrue);
  });

  test('onResponse logs the status code and the data', () {
    final options = RequestOptions(path: '/x');
    final response = Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 200,
      data: {'ok': true},
    );

    final lines = _capturePrints(() {
      interceptor.onResponse(response, ResponseInterceptorHandler());
    });

    expect(lines.any((l) => l.contains('Status Code: 200')), isTrue);
    expect(lines.any((l) => l.contains('Data:') && l.contains('ok')), isTrue);
  });

  test('onError logs the message and the status code when a response is present', () async {
    final options = RequestOptions(path: '/x');
    final response = Response<String>(
      requestOptions: options,
      statusCode: 500,
      data: 'boom',
    );
    final error = DioException(
      requestOptions: options,
      message: 'server error',
      response: response,
    );

    final handler = ErrorInterceptorHandler();
    final lines = _capturePrints(() {
      interceptor.onError(error, handler);
    });
    // super.onError -> handler.next(error) completes the handler's future
    // with an error; nothing downstream consumes it in this test, so await
    // (and swallow) it here to avoid an unhandled-async-error test failure.
    try {
      await handler.future;
    } catch (_) {}

    expect(lines.any((l) => l.contains('Message: server error')), isTrue);
    expect(lines.any((l) => l.contains('URI: ${options.uri}')), isTrue);
    expect(lines.any((l) => l.contains('Status Code: 500')), isTrue);
    expect(lines.any((l) => l.contains('Data:') && l.contains('boom')), isTrue);
  });

  test('onError does not log a status code or data when there is no response', () async {
    final options = RequestOptions(path: '/x');
    final error = DioException(requestOptions: options, message: 'timeout');

    final handler = ErrorInterceptorHandler();
    final lines = _capturePrints(() {
      interceptor.onError(error, handler);
    });
    try {
      await handler.future;
    } catch (_) {}

    expect(lines.any((l) => l.contains('Message: timeout')), isTrue);
    expect(lines.any((l) => l.startsWith('Status Code:')), isFalse);
    expect(lines.any((l) => l.startsWith('Data:')), isFalse);
  });
}
