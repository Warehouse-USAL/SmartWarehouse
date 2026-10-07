import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults status to 999 when none is given', () {
    final response = HttpResponse<String>(data: 'x');

    expect(response.status, '999');
    expect(response.statusCode, 999);
  });

  test('keeps the provided status and parses it', () {
    final response = HttpResponse<String>(data: 'x', status: '200');

    expect(response.status, '200');
    expect(response.statusCode, 200);
  });

  test('statusCode is null when the status is not numeric', () {
    final response = HttpResponse<String>(status: 'boom');

    expect(response.statusCode, isNull);
  });

  test('data is null when not provided', () {
    expect(HttpResponse<String>().data, isNull);
  });
}
