import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/data/dtos/order_tracking_detail_response_dto.dart';
import 'package:order_tracking/src/data/dtos/ws_order_event_dto.dart';
import 'package:order_tracking/src/data/mappers/order_tracking_mapper.dart';
import 'package:order_tracking/src/domain/entities/order_status_change.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemoteOrderTrackingRepository implements OrderTrackingRepository {
  RemoteOrderTrackingRepository({
    required this.httpHelper,
    required this.getToken,
    required this.baseUrl,
    required this.historyStore,
    WebSocketChannel Function(Uri uri)? connector,
    List<Duration>? retryDelays,
  }) : _connect = connector ?? WebSocketChannel.connect,
       _retryDelays = retryDelays ?? _defaultRetryDelays;

  static const _defaultRetryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 16),
    Duration(seconds: 30),
  ];

  final HttpHelper httpHelper;
  final String? Function() getToken;
  final OrderHistoryStore historyStore;

  /// Inyectable para tests; por defecto abre un WebSocket real.
  final WebSocketChannel Function(Uri uri) _connect;

  /// Backoff de reconexión; inyectable para que los tests no duerman.
  final List<Duration> _retryDelays;

  /// HTTP base URL (e.g. `http://10.0.2.2:8080`).
  /// watchOrder replaces the scheme to ws:// internally.
  final String baseUrl;

  /// Decodifica el `sub` (userId) del payload del JWT. El back registra los
  /// handlers WS bajo `/ws/v1/orders/{userId}` con un interceptor que matchea
  /// el `userId` del JWT contra el del path — necesitamos el id, no solo el
  /// token, para construir la URL.
  static String? _userIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    try {
      // No usamos GET /orders global: en su lugar, leemos los IDs de las
      // órdenes que el usuario creó en este device (persisted via
      // OrderHistoryStore) y hacemos GET /orders/{id} por cada uno en
      // paralelo.
      final ids = await historyStore.getOrderIds();
      if (ids.isEmpty) return const Right([]);

      final results = await Future.wait(ids.map(getOrderById));
      final orders = <Order>[];
      var transientFailures = 0;
      for (var i = 0; i < ids.length; i++) {
        results[i].fold((failure) {
          if (failure.notFound) {
            // 404 definitivo: la orden ya no existe en el backend; se poda
            // del historial local para no re-consultarla en cada refresh.
            unawaited(historyStore.removeOrderId(ids[i]));
          } else {
            transientFailures++;
          }
        }, orders.add);
      }
      // Si había órdenes y no se pudo traer NINGUNA por errores que no son
      // 404, es un problema de red/permisos: devolver Left para que la UI
      // muestre error con reintento, no el empty state "Sin órdenes".
      if (orders.isEmpty && transientFailures > 0) {
        return const Left(OrderTrackingFailure('Error de red'));
      }
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(orders);
    } catch (e, st) {
      log('getOrders error', error: e, stackTrace: st);
      return const Left(OrderTrackingFailure('Error de red'));
    }
  }

  @override
  Future<Either<OrderTrackingFailure, Order>> getOrderById(String id) async {
    try {
      final result = await httpHelper.get('/orders/$id');
      return await result.fold(
        (error) => Left(
          OrderTrackingFailure(_mapError(error), error.statusCode == 404),
        ),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderTrackingFailure('Respuesta inválida'));
          }
          final dto = OrderTrackingDetailResponseDto.fromJson(data);
          return Right(dto.order.toEntity());
        },
      );
    } catch (e, st) {
      log('getOrderById error', error: e, stackTrace: st);
      return const Left(OrderTrackingFailure('Error de red'));
    }
  }

  @override
  Stream<Order> watchOrder(String id) {
    final controller = StreamController<Order>();
    final holder = _ChannelHolder();
    controller.onCancel = () {
      // Cerrar el socket activo rompe el `await for` del loop; sin esto la
      // conexión quedaba abierta hasta el próximo mensaje del server.
      holder.closeChannel();
      return controller.close();
    };
    _connectWithRetry(id, controller, holder);
    return controller.stream;
  }

  void _connectWithRetry(
    String id,
    StreamController<Order> controller,
    _ChannelHolder holder,
  ) async {
    int attempt = 0;

    while (!controller.isClosed) {
      try {
        // Backend guideline: REST fetch before subscribing to WS. Correr
        // esto en cada reconexión además re-sincroniza el estado perdido
        // durante la desconexión y, si el token expiró en el medio, el GET
        // dispara el refresh vía HTTP antes de reabrir el socket.
        final restResult = await getOrderById(id);
        restResult.fold(
          (failure) {
            if (!controller.isClosed) {
              controller.addError(Exception(failure.message));
            }
          },
          (order) {
            if (!controller.isClosed) controller.add(order);
          },
        );

        final token = getToken();
        if (token == null) {
          if (!controller.isClosed) {
            controller.addError(Exception('No autenticado'));
          }
          return;
        }
        final userId = _userIdFromToken(token);
        if (userId == null) {
          if (!controller.isClosed) {
            controller.addError(Exception('Token inválido'));
          }
          return;
        }

        final wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
        final channel = _connect(
          Uri.parse('$wsUrl/ws/v1/orders/$userId?token=$token'),
        );
        holder.channel = channel;

        await for (final message in channel.stream) {
          if (controller.isClosed) break;
          // Recién un mensaje recibido prueba que la conexión sirve: si el
          // reset se hace al conectar, un backend que acepta el socket y lo
          // corta enseguida deja el backoff clavado en el mínimo.
          attempt = 0;
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final event = WsOrderEventDto.fromJson(json);
            if (event.event == 'order.updated' && event.payload.id == id) {
              final updated = await getOrderById(id);
              updated.fold((_) {}, (order) {
                if (!controller.isClosed) controller.add(order);
              });
            }
          } catch (_) {
            // Non-parseable WS message: ignore
          }
        }
      } catch (_) {
        // Error path falls through to the shared backoff below
      } finally {
        holder.closeChannel();
      }

      // Apply backoff on both clean server-close and error to prevent busy-loop
      if (!controller.isClosed) {
        final delay = _retryDelays[attempt.clamp(0, _retryDelays.length - 1)];
        attempt++;
        await Future<void>.delayed(delay);
      }
    }
  }

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() {
    final controller = StreamController<OrderStatusChange>();
    final holder = _ChannelHolder();
    controller.onCancel = () {
      holder.closeChannel();
      return controller.close();
    };
    _watchStatusChangesLoop(controller, holder);
    return controller.stream;
  }

  void _watchStatusChangesLoop(
    StreamController<OrderStatusChange> controller,
    _ChannelHolder holder,
  ) async {
    int attempt = 0;
    final Map<String, OrderStatus> cache = {};
    var seeded = false;

    while (!controller.isClosed) {
      try {
        // Re-sincronizar contra HTTP en CADA (re)conexión, no solo al
        // arrancar: los cambios de estado ocurridos mientras el WS estuvo
        // caído se recuperan acá (antes se perdían para siempre) y, si el
        // token expiró durante la desconexión, este GET dispara el refresh
        // antes de reabrir el socket. En la primera pasada solo se llena
        // el cache: no hay "cambios" que avisar.
        final seedResult = await getOrders();
        seedResult.fold((_) {}, (orders) {
          for (final o in orders) {
            final old = cache[o.id];
            if (seeded &&
                old != null &&
                old != o.status &&
                !controller.isClosed) {
              controller.add(
                OrderStatusChange(
                  orderId: o.id,
                  oldStatus: old,
                  newStatus: o.status,
                ),
              );
            }
            cache[o.id] = o.status;
          }
          seeded = true;
        });
        if (controller.isClosed) break;

        final token = getToken();
        if (token == null) {
          await Future<void>.delayed(const Duration(seconds: 5));
          continue;
        }
        final userId = _userIdFromToken(token);
        if (userId == null) {
          await Future<void>.delayed(const Duration(seconds: 5));
          continue;
        }

        final wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
        final channel = _connect(
          Uri.parse('$wsUrl/ws/v1/orders/$userId?token=$token'),
        );
        holder.channel = channel;

        await for (final message in channel.stream) {
          if (controller.isClosed) break;
          // Recién un mensaje recibido prueba que la conexión sirve: si el
          // reset se hace al conectar, un backend que acepta el socket y lo
          // corta enseguida deja el backoff clavado en el mínimo.
          attempt = 0;
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final event = WsOrderEventDto.fromJson(json);
            if (event.event == 'order.updated') {
              final orderId = event.payload.id;
              final newStatus = parseOrderStatus(event.payload.status);
              // Una orden que no está en el cache es nueva (creada después
              // del último seed): su estado inicial real es pending, así
              // que la primera transición también se avisa (antes se
              // tragaba por el guard de oldStatus == null).
              final oldStatus = cache[orderId] ?? OrderStatus.pending;
              if (oldStatus != newStatus) {
                controller.add(
                  OrderStatusChange(
                    orderId: orderId,
                    oldStatus: oldStatus,
                    newStatus: newStatus,
                  ),
                );
              }
              cache[orderId] = newStatus;
            }
          } catch (_) {
            // Non-parseable WS message: ignore
          }
        }
      } catch (_) {
        // Error path falls through to shared backoff below
      } finally {
        holder.closeChannel();
      }

      if (!controller.isClosed) {
        final delay = _retryDelays[attempt.clamp(0, _retryDelays.length - 1)];
        attempt++;
        await Future<void>.delayed(delay);
      }
    }
  }

  String _mapError(HttpResponseError error) {
    if (error.statusCode == 404) return 'Orden no encontrada';
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'Sin permisos para ver órdenes';
    }
    return error.message ?? 'Error de red';
  }
}

/// Referencia mutable al socket activo de un loop de conexión: permite que
/// el `onCancel` del stream cierre el canal vigente (que cambia en cada
/// reconexión) y así corte el `await for` en curso.
class _ChannelHolder {
  WebSocketChannel? channel;

  void closeChannel() {
    unawaited(channel?.sink.close());
    channel = null;
  }
}
