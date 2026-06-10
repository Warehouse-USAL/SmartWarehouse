import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart' show Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:orders/orders.dart';

// ── Fake HttpHelper ──────────────────────────────────────────────────────────

class _FakeHttpHelper implements HttpHelper {
  Either<HttpResponseError, HttpResponse> Function(String path) getHandler =
      (_) => Right(HttpResponse(data: <String, dynamic>{'orders': []}));

  @override
  void init() {}

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      getHandler(path);

  @override
  Future<Either<HttpResponseError, HttpResponse>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOnTokenExpired = true,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(
    String path, {
    required Map<String, dynamic> data,
    required FilesData filesData,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async =>
      throw UnimplementedError();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeHttpHelper fakeHttp;
  late RemoteOrderTrackingRepository repo;

  setUp(() {
    fakeHttp = _FakeHttpHelper();
    repo = RemoteOrderTrackingRepository(
      httpHelper: fakeHttp,
      getToken: () => 'test-token',
      baseUrl: 'http://localhost:8080',
    );
  });

  group('getOrders', () {
    test('returns empty list when orders is []', () async {
      fakeHttp.getHandler = (_) =>
          Right(HttpResponse(data: <String, dynamic>{'orders': []}));
      final result = await repo.getOrders();
      expect(result.isRight(), true);
      result.fold((_) {}, (orders) => expect(orders, isEmpty));
    });

    test('parses orders list correctly', () async {
      fakeHttp.getHandler = (_) => Right(HttpResponse(
            data: <String, dynamic>{
              'orders': [
                {'id': 'o1', 'status': 'pending', 'items': []},
                {'id': 'o2', 'status': 'in_progress', 'items': []},
              ],
            },
          ));
      final result = await repo.getOrders();
      result.fold(
        (_) => fail('Expected Right'),
        (orders) {
          expect(orders.length, 2);
          expect(orders.any((o) => o.id == 'o1'), true);
          expect(orders.any((o) => o.status == OrderStatus.inProgress), true);
        },
      );
    });

    test('returns failure on HTTP error', () async {
      fakeHttp.getHandler = (_) => Left(HttpResponseError(
          errorType: 'server_error',
          message: 'Server error',
          statusCode: 500));
      final result = await repo.getOrders();
      expect(result.isLeft(), true);
    });

    test('returns failure when response is not a Map', () async {
      fakeHttp.getHandler = (_) => Right(HttpResponse(data: 'not a map'));
      final result = await repo.getOrders();
      expect(result.isLeft(), true);
    });
  });

  group('getOrderById', () {
    test('parses single order correctly', () async {
      fakeHttp.getHandler = (path) {
        expect(path, '/orders/ord-1');
        return Right(HttpResponse(
          data: <String, dynamic>{
            'order': {'id': 'ord-1', 'status': 'completed', 'items': []},
          },
        ));
      };
      final result = await repo.getOrderById('ord-1');
      result.fold(
        (_) => fail('Expected Right'),
        (order) {
          expect(order.id, 'ord-1');
          expect(order.status, OrderStatus.completed);
        },
      );
    });

    test('returns failure on HTTP error', () async {
      fakeHttp.getHandler = (_) => Left(HttpResponseError(
          errorType: 'not_found', message: 'Not found', statusCode: 404));
      final result = await repo.getOrderById('nonexistent');
      expect(result.isLeft(), true);
    });
  });

  group('watchOrder', () {
    test('emits order from REST fetch immediately on subscribe', () async {
      fakeHttp.getHandler = (path) {
        if (path == '/orders/ord-1') {
          return Right(HttpResponse(
            data: <String, dynamic>{
              'order': {'id': 'ord-1', 'status': 'pending', 'items': []},
            },
          ));
        }
        return Right(HttpResponse(data: <String, dynamic>{'orders': []}));
      };

      final order = await repo.watchOrder('ord-1').first;
      expect(order.id, 'ord-1');
      expect(order.status, OrderStatus.pending);
    });
  });
}
