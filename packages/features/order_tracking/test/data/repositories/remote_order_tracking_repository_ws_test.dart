import 'dart:async';
import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:dio/dio.dart' show Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:orders/orders.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeHttpHelper implements HttpHelper {
  Either<HttpResponseError, HttpResponse> Function(String path) getHandler =
      (_) => Left(HttpResponseError(
          errorType: 'nf', message: 'Not found', statusCode: 404));

  @override
  String get baseUrl => 'http://localhost:8080';

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHistoryStore implements OrderHistoryStore {
  List<String> ids = const [];

  @override
  Future<List<String>> getOrderIds() async => ids;

  @override
  Future<void> addOrderId(String id) async => ids = [id, ...ids];

  @override
  Future<void> clear() async => ids = const [];
}

/// Canal WS falso: el test empuja mensajes con [emit] y simula la caída del
/// server con [serverClose]. El `sink.close()` del repo (cierre desde el
/// cliente) también cierra el stream, cortando el `await for` como en el
/// socket real.
class _FakeWsChannel implements WebSocketChannel {
  final StreamController<dynamic> incoming = StreamController<dynamic>();
  late final _FakeWsSink _sink = _FakeWsSink(this);

  bool get closed => incoming.isClosed;

  void emit(Map<String, dynamic> json) => incoming.add(jsonEncode(json));

  Future<void> serverClose() => incoming.close();

  @override
  Stream<dynamic> get stream => incoming.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWsSink implements WebSocketSink {
  _FakeWsSink(this._channel);

  final _FakeWsChannel _channel;

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    if (!_channel.incoming.isClosed) await _channel.incoming.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// JWT sin firma con el `sub` dado — alcanza para `_userIdFromToken`.
String _jwtWithSub(String sub) {
  String enc(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc({'sub': sub})}.firma';
}

Either<HttpResponseError, HttpResponse> _orderResponse(
  String id,
  String status,
) =>
    Right(HttpResponse(data: <String, dynamic>{
      'order': {'id': id, 'status': status, 'items': <dynamic>[]},
    }));

Future<void> _waitFor(bool Function() cond) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!cond() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(cond(), isTrue, reason: 'timeout esperando la condición');
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _FakeHttpHelper fakeHttp;
  late _FakeHistoryStore store;
  late List<_FakeWsChannel> channels;
  late RemoteOrderTrackingRepository repo;

  setUp(() {
    fakeHttp = _FakeHttpHelper();
    store = _FakeHistoryStore();
    channels = [];
    repo = RemoteOrderTrackingRepository(
      httpHelper: fakeHttp,
      getToken: () => _jwtWithSub('u1'),
      baseUrl: 'http://localhost:8080',
      historyStore: store,
      connector: (_) {
        final channel = _FakeWsChannel();
        channels.add(channel);
        return channel;
      },
      // Sin backoff real: los tests no duermen.
      retryDelays: const [Duration.zero],
    );
  });

  group('watchOrderStatusChanges', () {
    test('recupera cambios ocurridos mientras el WS estuvo caído', () async {
      store.ids = ['o1'];
      fakeHttp.getHandler = (_) => _orderResponse('o1', 'pending');

      final changes = <OrderStatusChange>[];
      final sub = repo.watchOrderStatusChanges().listen(changes.add);
      await _waitFor(() => channels.length == 1);

      // Con el socket caído, la orden avanza en el backend. El re-seed de la
      // reconexión tiene que emitir el cambio (antes se perdía para siempre).
      fakeHttp.getHandler = (_) => _orderResponse('o1', 'in_progress');
      await channels.first.serverClose();

      await _waitFor(() => changes.isNotEmpty);
      expect(changes.single.orderId, 'o1');
      expect(changes.single.oldStatus, OrderStatus.pending);
      expect(changes.single.newStatus, OrderStatus.inProgress);
      expect(channels.length, greaterThanOrEqualTo(2), reason: 'reconectó');

      await sub.cancel();
    });

    test('la primera transición de una orden nueva también se avisa',
        () async {
      // Orden creada después del seed: no está en el cache. Su estado
      // inicial real es pending, así que pending -> in_progress se emite
      // (antes el guard de oldStatus == null la tragaba).
      final changes = <OrderStatusChange>[];
      final sub = repo.watchOrderStatusChanges().listen(changes.add);
      await _waitFor(() => channels.length == 1);

      channels.first.emit({
        'event': 'order.updated',
        'payload': {'id': 'o9', 'status': 'in_progress'},
      });

      await _waitFor(() => changes.isNotEmpty);
      expect(changes.single.orderId, 'o9');
      expect(changes.single.oldStatus, OrderStatus.pending);
      expect(changes.single.newStatus, OrderStatus.inProgress);

      await sub.cancel();
    });

    test('cancelar la suscripción cierra el socket activo', () async {
      final sub = repo.watchOrderStatusChanges().listen((_) {});
      await _waitFor(() => channels.length == 1);

      await sub.cancel();

      await _waitFor(() => channels.last.closed);
    });

    test('un evento con el mismo estado del cache no re-emite', () async {
      store.ids = ['o1'];
      fakeHttp.getHandler = (_) => _orderResponse('o1', 'in_progress');

      final changes = <OrderStatusChange>[];
      final sub = repo.watchOrderStatusChanges().listen(changes.add);
      await _waitFor(() => channels.length == 1);

      channels.first.emit({
        'event': 'order.updated',
        'payload': {'id': 'o1', 'status': 'in_progress'},
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(changes, isEmpty);

      await sub.cancel();
    });
  });

  group('watchOrder', () {
    test('cancelar la suscripción cierra el socket activo', () async {
      fakeHttp.getHandler = (_) => _orderResponse('ord-1', 'pending');

      final sub = repo.watchOrder('ord-1').listen((_) {});
      await _waitFor(() => channels.length == 1);

      await sub.cancel();

      await _waitFor(() => channels.last.closed);
    });

    test('un mensaje del WS refresca la orden por REST', () async {
      var status = 'pending';
      fakeHttp.getHandler = (_) => _orderResponse('ord-1', status);

      final orders = <Order>[];
      final sub = repo.watchOrder('ord-1').listen(orders.add);
      await _waitFor(() => channels.length == 1);
      await _waitFor(() => orders.length == 1);

      status = 'completed';
      channels.first.emit({
        'event': 'order.updated',
        'payload': {'id': 'ord-1', 'status': 'completed'},
      });

      await _waitFor(() => orders.length == 2);
      expect(orders.last.status, OrderStatus.completed);

      await sub.cancel();
    });
  });
}
