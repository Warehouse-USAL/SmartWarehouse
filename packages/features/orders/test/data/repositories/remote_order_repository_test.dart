import 'package:catalog/catalog.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orders/src/data/repositories/remote_order_repository.dart';
import 'package:orders/src/data/storage/order_history_store.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';

class _MockHttpHelper extends Mock implements HttpHelper {}

class _FakeHistoryStore implements OrderHistoryStore {
  final List<String> ids = [];

  @override
  Future<void> addOrderId(String id) async => ids.insert(0, id);

  @override
  Future<List<String>> getOrderIds() async => ids;

  @override
  Future<void> removeOrderId(String id) async => ids.remove(id);

  @override
  Future<void> clear() async => ids.clear();
}

void main() {
  late _MockHttpHelper http;
  late RemoteOrderRepository repo;

  setUp(() {
    http = _MockHttpHelper();
    repo = RemoteOrderRepository(
      httpHelper: http,
      historyStore: _FakeHistoryStore(),
    );
  });

  /// Simula el error que armaría el DioHttpHelper a partir de la respuesta
  /// del back (`{"error": {"code": ..., "message": ...}}` → reason/message).
  void stubPostError({required int statusCode, String? reason}) {
    when(() => http.post(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Left(
        HttpResponseError(
          errorType: null,
          message: null,
          statusCode: statusCode,
          reason: reason,
        ),
      ),
    );
  }

  Future<String?> createAndGetFailureMessage() async {
    final result = await repo.create(
      items: const [
        OrderItem(
          productId: 'p1',
          productName: 'Caja',
          quantity: 1,
          unitPrice: Money(amount: 100, currency: 'ARS'),
        ),
      ],
      destination: OrderDestination.defaults,
    );
    return result.fold(
      (failure) => failure.message,
      (_) => fail('Se esperaba Left'),
    );
  }

  group('create → _mapError de los códigos nuevos del back', () {
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
