import 'dart:async';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:commons/helpers/http/entities/http_response_error.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:orders/src/data/dtos/create_order_request_dto.dart';
import 'package:orders/src/data/dtos/order_response_dto.dart';
import 'package:orders/src/data/mappers/order_mapper.dart';
import 'package:orders/src/data/storage/order_history_store.dart';
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_destination.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/repositories/order_repository.dart';

/// Talks to `POST /orders` and `POST /orders/{id}/cancel`.
///
/// Body shape (snake_case por JacksonConfig):
/// ```json
/// {
///   "items": [{ "product_id": "p1", "quantity": 2 }],
///   "destination_area": "Bay 14"
/// }
/// ```
class RemoteOrderRepository implements OrderRepository {
  RemoteOrderRepository({
    required this.httpHelper,
    required this.historyStore,
  });

  final HttpHelper httpHelper;
  final OrderHistoryStore historyStore;

  @override
  Future<Either<OrderFailure, Order>> create({
    required List<OrderItem> items,
    required OrderDestination destination,
  }) async {
    try {
      // TODO(checkout): reemplazar por un formulario de dirección en el cart.
      // Por ahora hardcodeado para satisfacer el contrato del back (PR #55):
      // street + postal_code son requeridos.
      const placeholderAddress = AddressDto(
        street: 'Av. Siempre Viva 742',
        postalCode: '1414',
      );
      final body = CreateOrderRequestDto(
        items: items
            .map((i) =>
                CreateOrderItemDto(productId: i.productId, quantity: i.quantity))
            .toList(growable: false),
        destinationArea: destination.area,
        address: placeholderAddress,
      ).toJson();

      final result = await httpHelper.post('/orders', data: body);
      return result.fold(
        (error) => Left(OrderFailure(_mapError(error))),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(OrderFailure('Respuesta inválida'));
          }
          final dto = OrderResponseDto.fromJson(data);
          final order = dto.order.toEntity(fallbackItems: items);
          // Persistimos el ID en local: el order_tracking lo va a usar para
          // listar las órdenes propias sin depender de GET /orders global.
          unawaited(historyStore.addOrderId(order.id));
          return Right(order);
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
}
