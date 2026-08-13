import 'package:commons/commons.dart';
import 'package:commons/utils/image_url_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_support/test_support.dart';

void main() {
  setUp(resetInjector);

  group('without an injected HttpHelper', () {
    test('returns null for null input', () {
      expect(ImageUrlResolver.resolve(null), isNull);
    });

    test('returns null for empty input', () {
      expect(ImageUrlResolver.resolve(''), isNull);
    });

    test('passes through absolute http and https urls', () {
      expect(
        ImageUrlResolver.resolve('https://picsum.photos/200'),
        'https://picsum.photos/200',
      );
      expect(
        ImageUrlResolver.resolve('http://example.com/a.png'),
        'http://example.com/a.png',
      );
    });

    test('passes through data uris', () {
      expect(
        ImageUrlResolver.resolve('data:image/png;base64,AAA'),
        'data:image/png;base64,AAA',
      );
    });

    test('passes through values with no recognised shape', () {
      expect(ImageUrlResolver.resolve('weird-value'), 'weird-value');
    });

    test('returns the raw relative path when no baseUrl can be resolved', () {
      expect(
        ImageUrlResolver.resolve('/api/v1/files/images/a.png'),
        '/api/v1/files/images/a.png',
      );
    });
  });

  group('with an explicit baseUrl', () {
    test('prepends it to a relative path', () {
      expect(
        ImageUrlResolver.resolve(
          '/api/v1/files/images/a.png',
          baseUrl: 'https://api.example.com',
        ),
        'https://api.example.com/api/v1/files/images/a.png',
      );
    });

    test('does not produce a double slash when baseUrl has a trailing slash', () {
      expect(
        ImageUrlResolver.resolve(
          '/api/v1/files/images/a.png',
          baseUrl: 'https://api.example.com/',
        ),
        'https://api.example.com/api/v1/files/images/a.png',
      );
    });

    test('is ignored for an absolute url', () {
      expect(
        ImageUrlResolver.resolve(
          'https://picsum.photos/200',
          baseUrl: 'https://api.example.com',
        ),
        'https://picsum.photos/200',
      );
    });
  });

  group('with an injected HttpHelper', () {
    test('falls back to the registered helper baseUrl', () {
      final http = registerMock<HttpHelper>(MockHttpHelper());
      when(() => http.baseUrl).thenReturn('https://injected.example.com');

      expect(
        ImageUrlResolver.resolve('/api/v1/files/images/a.png'),
        'https://injected.example.com/api/v1/files/images/a.png',
      );
    });

    test('an explicit baseUrl wins over the injected one', () {
      final http = registerMock<HttpHelper>(MockHttpHelper());
      when(() => http.baseUrl).thenReturn('https://injected.example.com');

      expect(
        ImageUrlResolver.resolve(
          '/a.png',
          baseUrl: 'https://explicit.example.com',
        ),
        'https://explicit.example.com/a.png',
      );
      verifyNever(() => http.baseUrl);
    });
  });
}
