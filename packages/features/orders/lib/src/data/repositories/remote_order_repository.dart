import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';
import 'package:orders/src/domain/repositories/order_repository.dart';

/// Talks to `POST /orders` y `POST /orders/:id/cancel` según contrato
/// `docs/superpowers/specs/2026-05-19-api-contracts-design.md`.
class RemoteOrderRepository implements OrderRepository {
  RemoteOrderRepository({required this.httpHelper});

  final HttpHelper httpHelper;

  @override
  Future<Either<OrderFailure, Order>> create({
    required List<OrderItem> items,
    required OrderDestination destination,
  }) async {
    try {
      final result = await httpHelper.post(
        '/orders',
        data: {
          'items': items
              .map((i) => {'product_id': i.productId, 'quantity': i.quantity})
              .toList(),
          'destination': {
            'area': destination.area,
            'address_line': destination.addressLine,
          },
        },
      );
      return result.fold(
        (error) => Left(OrderFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderFailure('Respuesta inválida'));
          }
          final raw = data['order'];
          if (raw is! Map<String, dynamic>) {
            return const Left(OrderFailure('Respuesta inválida'));
          }
          return Right(_parseOrder(raw, fallbackItems: items));
        },
      );
    } catch (e, st) {
      log('createOrder error', error: e, stackTrace: st);
      return const Left(OrderFailure('Error de red'));
    }
  }

  @override
  Future<Either<OrderFailure, Unit>> cancel({
    required String id,
    required String reason,
  }) async {
    try {
      final result = await httpHelper.post(
        '/orders/$id/cancel',
        data: {'reason': reason},
      );
      return result.fold(
        (error) => Left(OrderFailure(_mapError(error))),
        (_) => const Right(unit),
      );
    } catch (e, st) {
      log('cancelOrder error', error: e, stackTrace: st);
      return const Left(OrderFailure('Error de red'));
    }
  }

  String _mapError(HttpResponseError error) {
    if (error.statusCode == 401 || error.statusCode == 403) {
      return 'No tenés permisos para crear órdenes';
    }
    if (error.statusCode == 400) {
      return error.message ?? 'Datos inválidos en la orden';
    }
    return error.message ?? 'No se pudo crear la orden';
  }

  Order _parseOrder(Map<String, dynamic> json, {required List<OrderItem> fallbackItems}) {
    final id = (json['id'] as String?) ?? '';
    final status = _parseStatus(json['status'] as String?);

    final tsJson = json['timestamps'];
    DateTime createdAt = DateTime.now();
    if (tsJson is Map<String, dynamic>) {
      final created = tsJson['created_at'] as String?;
      if (created != null) {
        createdAt = DateTime.tryParse(created) ?? createdAt;
      }
    } else if (json['created_at'] is String) {
      createdAt = DateTime.tryParse(json['created_at'] as String) ?? createdAt;
    }

    // El backend no devuelve montos en /orders — el total se computa local.
    final currency = fallbackItems.isEmpty ? 'ARS' : fallbackItems.first.unitPrice.currency;
    var total = Money.zero(currency);
    for (final i in fallbackItems) {
      total = total + i.subtotal;
    }

    return Order(
      id: id,
      items: fallbackItems,
      total: total,
      status: status,
      createdAt: createdAt,
    );
  }

  OrderStatus _parseStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'in_progress':
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'completed':
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
