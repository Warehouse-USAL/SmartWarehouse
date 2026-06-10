import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/src/data/dtos/order_list_response_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_detail_response_dto.dart';
import 'package:order_tracking/src/data/dtos/ws_order_event_dto.dart';
import 'package:order_tracking/src/data/mappers/order_tracking_mapper.dart';
import 'package:order_tracking/src/domain/repositories/order_tracking_repository.dart';
import 'package:orders/orders.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RemoteOrderTrackingRepository implements OrderTrackingRepository {
  RemoteOrderTrackingRepository({
    required this.httpHelper,
    required this.getToken,
    required this.baseUrl,
  });

  final HttpHelper httpHelper;
  final String? Function() getToken;

  /// HTTP base URL (e.g. `http://10.0.2.2:8080`).
  /// watchOrder replaces the scheme to ws:// internally.
  final String baseUrl;

  @override
  Future<Either<OrderTrackingFailure, List<Order>>> getOrders() async {
    try {
      final result = await httpHelper.get('/orders');
      return result.fold(
        (error) => Left(OrderTrackingFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderTrackingFailure('Respuesta inválida'));
          }
          final dto = OrderListResponseDto.fromJson(data);
          final orders = dto.orders.map((o) => o.toEntity()).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return Right(orders);
        },
      );
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

        final wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
        final channel =
            WebSocketChannel.connect(Uri.parse('$wsUrl/ws?token=$token'));
        attempt = 0;

        await for (final message in channel.stream) {
          if (controller.isClosed) break;
          try {
            final json =
                jsonDecode(message as String) as Map<String, dynamic>;
            final event = WsOrderEventDto.fromJson(json);
            if (event.event == 'order.updated' &&
                event.payload.orderId == id) {
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
        if (controller.isClosed) break;
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
