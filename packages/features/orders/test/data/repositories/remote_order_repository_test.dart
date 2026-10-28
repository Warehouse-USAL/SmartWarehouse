import 'package:catalog/catalog.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart' show Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:orders/src/data/repositories/remote_order_repository.dart';
import 'package:orders/src/data/storage/order_history_store.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';

// ── Fake HttpHelper (mismo patrón que en order_tracking) ────────────────────

class _FakeHttpHelper implements HttpHelper {
  Either<HttpResponseError, HttpResponse> Function(String path, dynamic data)
  postHandler = (_, __) => throw UnimplementedError();

  @override
  String get baseUrl => 'http://localhost:8080';

  @override
  void init() {}

  @override
  Future<Either<HttpResponseError, HttpResponse>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool retryOnTokenExpired = true,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async => postHandler(path, data);

  @override
  Future<Either<HttpResponseError, HttpResponse>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool noCache = false,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async => throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async => throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool external = false,
  }) async => throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async => throw UnimplementedError();

  @override
  Future<Either<HttpResponseError, HttpResponse>> postImages(
    String path, {
    required Map<String, dynamic> data,
    required FilesData filesData,
    bool external = false,
    Map<String, dynamic>? headers,
  }) async => throw UnimplementedError();
}

class _FakeHistoryStore implements OrderHistoryStore {
  List<String> ids = const [];

  @override
  Future<List<String>> getOrderIds() async => ids;

  @override
  Future<void> addOrderId(String id) async => ids = [id, ...ids];

  @override
  Future<void> removeOrderId(String id) async =>
      ids = ids.where((i) => i != id).toList();

  @override
  Future<void> clear() async => ids = const [];
}

OrderItem _item(
  String id, {
  int quantity = 1,
  bool fromRecommendation = false,
}) => OrderItem(
  productId: id,
  productName: 'Producto $id',
  quantity: quantity,
  unitPrice: const Money(amount: 1000, currency: 'ARS'),
  fromRecommendation: fromRecommendation,
);

void main() {
  late _FakeHttpHelper fakeHttp;
  late RemoteOrderRepository repo;

  setUp(() {
    fakeHttp = _FakeHttpHelper();
    repo = RemoteOrderRepository(
      httpHelper: fakeHttp,
      historyStore: _FakeHistoryStore(),
    );
  });

  group('create', () {
    test('el body del POST lleva from_recommendation por ítem', () async {
      dynamic postedBody;
      fakeHttp.postHandler = (path, data) {
        expect(path, '/orders');
        postedBody = data;
        return Right(
          HttpResponse(
            data: <String, dynamic>{
              'order': {'id': 'ord-1', 'status': 'pending', 'items': []},
            },
          ),
        );
      };

      final result = await repo.create(
        items: [
          _item('a', quantity: 2),
          _item('b', quantity: 1, fromRecommendation: true),
        ],
        destination: OrderDestination.defaults,
      );

      expect(result.isRight(), isTrue);
      final items = (postedBody as Map)['items'] as List<dynamic>;
      expect(items, [
        {'product_id': 'a', 'quantity': 2, 'from_recommendation': false},
        {'product_id': 'b', 'quantity': 1, 'from_recommendation': true},
      ]);
    });

    test('la orden creada conserva el flag en los items de dominio', () async {
      // El back no devuelve el flag: la entidad sale de los fallbackItems,
      // que son exactamente los que enviamos.
      fakeHttp.postHandler = (_, __) => Right(
        HttpResponse(
          data: <String, dynamic>{
            'order': {'id': 'ord-2', 'status': 'pending', 'items': []},
          },
        ),
      );

      final result = await repo.create(
        items: [_item('a', fromRecommendation: true)],
        destination: OrderDestination.defaults,
      );

      result.fold(
        (_) => fail('Expected Right'),
        (order) => expect(order.items.single.fromRecommendation, isTrue),
      );
    });
  });

  group('create → _mapError de los códigos nuevos del back', () {
    /// Simula el error que armaría el DioHttpHelper a partir de la respuesta
    /// del back (`{"error": {"code": ..., "message": ...}}` → reason).
    void stubPostError({required int statusCode, String? reason}) {
      fakeHttp.postHandler = (_, __) => Left(
        HttpResponseError(
          errorType: null,
          message: null,
          statusCode: statusCode,
          reason: reason,
        ),
      );
    }

    Future<String?> createAndGetFailureMessage() async {
      final result = await repo.create(
        items: [_item('p1')],
        destination: OrderDestination.defaults,
      );
      return result.fold(
        (failure) => failure.message,
        (_) => fail('Se esperaba Left'),
      );
    }

    test(
      '409 genérico (STOCK_CHANGE_CONFLICT) invita a revisar y reintentar',
      () async {
        stubPostError(statusCode: 409, reason: 'STOCK_CHANGE_CONFLICT');
        expect(
          await createAndGetFailureMessage(),
          'El stock cambió mientras confirmabas. Revisá el pedido y reintentá.',
        );
      },
    );

    test('409 sin reason cae al mensaje de conflicto de stock', () async {
      // Defensivo: si el back no manda `error.code`, igual explicamos el 409
      // con el caso más probable en vez de un error genérico.
      stubPostError(statusCode: 409);
      expect(
        await createAndGetFailureMessage(),
        'El stock cambió mientras confirmabas. Revisá el pedido y reintentá.',
      );
    });

    test('409 con IDEMPOTENCY_REQUEST_IN_PROGRESS pide esperar', () async {
      stubPostError(statusCode: 409, reason: 'IDEMPOTENCY_REQUEST_IN_PROGRESS');
      expect(
        await createAndGetFailureMessage(),
        'Tu orden se está procesando, esperá unos segundos antes de '
        'reintentar.',
      );
    });

    test('503 avisa que el servicio está saturado y que reintente', () async {
      stubPostError(statusCode: 503);
      expect(
        await createAndGetFailureMessage(),
        'El depósito está saturado en este momento. Reintentá en unos '
        'segundos.',
      );
    });
  });
}
