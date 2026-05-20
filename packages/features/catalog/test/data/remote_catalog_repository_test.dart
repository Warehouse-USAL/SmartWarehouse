import 'package:catalog/src/data/repositories/remote_catalog_repository.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpHelper implements HttpHelper {
  _FakeHttpHelper(this._response);
  final Either<HttpResponseError, HttpResponse> _response;
  Map<String, dynamic>? lastQueryParams;
  String? lastPath;

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async {
    lastPath = path;
    lastQueryParams = queryParameters;
    return _response;
  }

  // Other methods unused — throw to surface accidental calls.
  @override
  void init() {}
  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, bool retryOnTokenExpired = true, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(String path, {required Map<String, dynamic> data, required FilesData filesData, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers, bool external = false}) =>
      throw UnimplementedError();
  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, bool external = false, Map<String, dynamic>? headers}) =>
      throw UnimplementedError();
}

HttpResponse _ok(Map<String, dynamic> body) =>
    HttpResponse(data: body, status: '200');

void main() {
  group('RemoteCatalogRepository.getProducts', () {
    test('passes page, page_size, search, category as query params', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': <Map<String, dynamic>>[],
        'pagination': {'page': 2, 'page_size': 20, 'total': 0, 'has_next': false},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      await repo.getProducts(page: 2, pageSize: 20, search: 'cafe', categoryId: 'home');

      expect(helper.lastPath, '/products');
      expect(helper.lastQueryParams, {
        'page': 2,
        'page_size': 20,
        'search': 'cafe',
        'category': 'home',
      });
    });

    test('omits empty/null filter params', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': <Map<String, dynamic>>[],
        'pagination': {'page': 1, 'page_size': 20, 'total': 0, 'has_next': false},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      await repo.getProducts();

      expect(helper.lastQueryParams, {'page': 1, 'page_size': 20});
    });

    test('parses items and pagination metadata', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': [
          {
            'id': 'p1',
            'sku': 'SKU-001',
            'name': 'Test',
            'category': 'electronics',
          }
        ],
        'pagination': {'page': 1, 'page_size': 20, 'total': 137, 'has_next': true},
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      final result = await repo.getProducts();
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(1));
          expect(page.items.first.id, 'p1');
          expect(page.page, 1);
          expect(page.pageSize, 20);
          expect(page.total, 137);
          expect(page.hasNext, isTrue);
        },
      );
    });

    test('falls back to items.length when pagination block missing', () async {
      final helper = _FakeHttpHelper(Right(_ok({
        'products': [
          {'id': 'p1', 'sku': 'SKU-001', 'name': 'A', 'category': 'home'},
          {'id': 'p2', 'sku': 'SKU-002', 'name': 'B', 'category': 'home'},
        ],
      })));
      final repo = RemoteCatalogRepository(httpHelper: helper);

      final result = await repo.getProducts();
      result.fold(
        (_) => fail('expected Right'),
        (page) {
          expect(page.items, hasLength(2));
          expect(page.page, 1);
          expect(page.pageSize, 2);
          expect(page.total, 2);
          expect(page.hasNext, isFalse);
        },
      );
    });
  });
}
