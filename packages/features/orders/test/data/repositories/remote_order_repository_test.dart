import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/data/repositories/remote_order_repository.dart';

class _MockHttp extends Mock implements HttpHelper {}

class _MockStore extends Mock implements OrderHistoryStore {}

void main() {
  late _MockHttp http;
  late RemoteOrderRepository repo;

  setUp(() {
    http = _MockHttp();
    repo = RemoteOrderRepository(httpHelper: http, historyStore: _MockStore());
  });

  Future<String?> failWith(HttpResponseError error) async {
    when(
      () => http.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) async => Left(error));
    final result = await repo.create(
      items: const [],
      destination: const OrderDestination(
        area: 'Bay 1',
        street: 's',
        postalCode: 'p',
      ),
    );
    return result.fold((f) => f.message, (_) => null);
  }

  HttpResponseError err(int status, {String? reason, String? message}) =>
      HttpResponseError(
        errorType: null,
        message: message,
        statusCode: status,
        reason: reason,
      );

  group('create: errores del backend', () {
    test('409 STOCK_CHANGE_CONFLICT -> mensaje explícito', () async {
      expect(
        await failWith(err(409, reason: 'STOCK_CHANGE_CONFLICT', message: 'x')),
        'Otros cambios de stock están en curso, reintentá',
      );
    });

    test('409 IDEMPOTENCY_REQUEST_IN_PROGRESS -> mensaje explícito', () async {
      expect(
        await failWith(err(409, reason: 'IDEMPOTENCY_REQUEST_IN_PROGRESS')),
        contains('ya se está procesando'),
      );
    });

    test('503 DATABASE_UNAVAILABLE -> servicio no disponible', () async {
      expect(
        await failWith(err(503, reason: 'DATABASE_UNAVAILABLE')),
        'El servicio no está disponible, intentá de nuevo',
      );
    });

    test('503 sin código también se reconoce', () async {
      expect(
        await failWith(err(503)),
        'El servicio no está disponible, intentá de nuevo',
      );
    });

    test('sin cambios: 400 y desconocidos siguen igual', () async {
      expect(await failWith(err(400)), 'Datos inválidos en la orden');
      expect(await failWith(err(409, message: 'otro')), 'otro');
      expect(await failWith(err(500)), 'No se pudo crear la orden');
      expect(await failWith(err(403)), 'No tenés permisos para crear órdenes');
    });
  });
}
