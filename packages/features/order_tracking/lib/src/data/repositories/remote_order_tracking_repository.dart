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
  });

  final HttpHelper httpHelper;
  final String? Function() getToken;
  final OrderHistoryStore historyStore;

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
      // paralelo. Las que fallen (404, etc.) las filtramos.
      final ids = await historyStore.getOrderIds();
      if (ids.isEmpty) return const Right([]);

      final results = await Future.wait(ids.map(getOrderById));
      final orders = <Order>[];
      for (final r in results) {
        r.fold((_) {}, orders.add);
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
      return result.fold(
        (error) => Left(OrderTrackingFailure(_mapError(error))),
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
    controller.onCancel = controller.close;
    _connectWithRetry(id, controller);
    return controller.stream;
  }

  void _connectWithRetry(String id, StreamController<Order> controller) async {
    const delays = [1, 2, 4, 8, 16, 30];
    int attempt = 0;

    while (!controller.isClosed) {
      try {
        // Backend guideline: REST fetch before subscribing to WS
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
        final channel = WebSocketChannel.connect(
          Uri.parse('$wsUrl/ws/v1/orders/$userId?token=$token'),
        );
        attempt = 0;

        await for (final message in channel.stream) {
          if (controller.isClosed) break;
          try {
            final json =
                jsonDecode(message as String) as Map<String, dynamic>;
            final event = WsOrderEventDto.fromJson(json);
            if (event.event == 'order.updated' &&
                event.payload.id == id) {
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
      }

      // Apply backoff on both clean server-close and error to prevent busy-loop
      if (!controller.isClosed) {
        final delay = delays[attempt.clamp(0, delays.length - 1)];
        attempt++;
        await Future<void>.delayed(Duration(seconds: delay));
      }
    }
  }

  @override
  Stream<OrderStatusChange> watchOrderStatusChanges() {
    final controller = StreamController<OrderStatusChange>();
    controller.onCancel = controller.close;
    _watchStatusChangesLoop(controller);
    return controller.stream;
  }

  void _watchStatusChangesLoop(
    StreamController<OrderStatusChange> controller,
  ) async {
    const delays = [1, 2, 4, 8, 16, 30];
    int attempt = 0;
    final Map<String, OrderStatus> cache = {};

    // Seed cache with current order statuses before opening WS.
    final seedResult = await getOrders();
    seedResult.fold((_) {}, (orders) {
      for (final o in orders) {
        cache[o.id] = o.status;
      }
    });

    while (!controller.isClosed) {
      try {
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
        final channel = WebSocketChannel.connect(
          Uri.parse('$wsUrl/ws/v1/orders/$userId?token=$token'),
        );
        attempt = 0;

        await for (final message in channel.stream) {
          if (controller.isClosed) break;
          try {
            final json =
                jsonDecode(message as String) as Map<String, dynamic>;
            final event = WsOrderEventDto.fromJson(json);
            if (event.event == 'order.updated') {
              final orderId = event.payload.id;
              final newStatus = parseOrderStatus(event.payload.status);
              final oldStatus = cache[orderId];
              if (oldStatus != null && oldStatus != newStatus) {
                controller.add(OrderStatusChange(
                  orderId: orderId,
                  oldStatus: oldStatus,
                  newStatus: newStatus,
                ));
              }
              cache[orderId] = newStatus;
            }
          } catch (_) {
            // Non-parseable WS message: ignore
          }
        }
      } catch (_) {
        // Error path falls through to shared backoff below
      }

      if (!controller.isClosed) {
        final delay = delays[attempt.clamp(0, delays.length - 1)];
        attempt++;
        await Future<void>.delayed(Duration(seconds: delay));
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
