import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults statusCode to 999 when none is given', () {
    final error = HttpResponseError(errorType: 'network', message: 'offline');

    expect(error.statusCode, 999);
  });

  test('keeps the provided statusCode', () {
    final error = HttpResponseError(
      errorType: 'http',
      message: 'not found',
      statusCode: 404,
    );

    expect(error.statusCode, 404);
    expect(error.errorType, 'http');
    expect(error.message, 'not found');
  });

  test('optional fields default to null', () {
    final error = HttpResponseError(errorType: null, message: null);

    expect(error.reason, isNull);
    expect(error.stackTrace, isNull);
  });
}
