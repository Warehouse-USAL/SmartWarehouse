import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:catalog/catalog.dart';
import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/order_tracking.dart';
import 'package:profile/src/data/dtos/user_dto.dart';
import 'package:profile/src/data/mappers/profile_mapper.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_address.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';

/// Hits `GET /users/{id}` para los datos del perfil. El id sale del `sub`
/// del JWT (admin/SUPERADMIN tiene permiso para verse a sí mismo).
///
/// El historial de órdenes se construye leyendo los IDs persistidos en
/// `OrderHistoryStore` y haciendo `GET /orders/{id}` por cada uno —
/// reutilizamos la lógica que ya tiene `OrderTrackingRepository.getOrders`.
class RemoteProfileRepository implements ProfileRepository {
  RemoteProfileRepository({
    required this.httpHelper,
    required this.getToken,
    required this.orderTrackingRepository,
    required this.catalogRepository,
  });

  final HttpHelper httpHelper;
  final String? Function() getToken;
  final OrderTrackingRepository orderTrackingRepository;
  final CatalogRepository catalogRepository;

  @override
  Future<Either<ProfileFailure, ProfileUser>> getProfile() async {
    try {
      final token = getToken();
      if (token == null) {
        return const Left(ProfileFailure('No autenticado'));
      }
      final userId = _userIdFromToken(token);
      if (userId == null) {
        return const Left(ProfileFailure('Token inválido'));
      }
      final result = await httpHelper.get('/users/$userId');
      return result.fold(
        (error) => Left(ProfileFailure(error.message ?? 'Error obteniendo perfil')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(ProfileFailure('Respuesta inválida'));
          }
          final dto = UserDto.fromJson(data);
          return Right(dto.toProfileUser());
        },
      );
    } catch (e, st) {
      log('getProfile error', error: e, stackTrace: st);
      return const Left(ProfileFailure('Error de red'));
    }
  }

  @override
  Future<Either<ProfileFailure, List<OrderSummary>>> getOrderHistory() async {
    try {
      final result = await orderTrackingRepository.getOrders();
      return await result.fold(
        (failure) async =>
            Left(ProfileFailure(failure.message ?? 'Error obteniendo órdenes')),
        (orders) async {
          // El back no devuelve precios en /orders/{id}, los items vienen
          // con unitPrice=0. Para que el "gastado este mes" muestre un valor
          // real, traemos los products del catálogo en paralelo y calculamos
          // el total con el precio real.
          final ids = orders
              .expand((o) => o.items.map((i) => i.productId))
              .toSet()
              .toList(growable: false);
          final pairs = await Future.wait(
            ids.map(
              (id) async => MapEntry(id, await catalogRepository.getProductById(id)),
            ),
          );
          final priceByProduct = <String, int>{};
          for (final pair in pairs) {
            pair.value.fold((_) {}, (p) => priceByProduct[pair.key] = p.price.amount);
          }
          final summaries = orders.map((o) {
            final totalCents = o.items.fold<int>(
              0,
              (sum, i) => sum + (priceByProduct[i.productId] ?? 0) * i.quantity,
            );
            return o.toSummary().copyWith(totalAmount: totalCents / 100.0);
          }).toList(growable: false);
          return Right(summaries);
        },
      );
    } catch (e, st) {
      log('getOrderHistory error', error: e, stackTrace: st);
      return const Left(ProfileFailure('Error de red'));
    }
  }

  @override
  Future<Either<ProfileFailure, ProfileUser>> updateProfile({
    String? name,
    UserAddress? address,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (address != null) {
        body['address'] = {
          'street': address.street,
          'postal_code': address.postalCode,
          if (address.department != null && address.department!.trim().isNotEmpty)
            'department': address.department,
          if (address.floor != null && address.floor!.trim().isNotEmpty)
            'floor': address.floor,
        };
      }
      final result = await httpHelper.patch('/users/me', data: body);
      return result.fold(
        (error) =>
            Left(ProfileFailure(error.message ?? 'Error actualizando perfil')),
        (response) {
          final data = response.data;
          if (data is! Map<String, dynamic>) {
            return const Left(ProfileFailure('Respuesta inválida'));
          }
          final dto = UserDto.fromJson(data);
          return Right(dto.toProfileUser());
        },
      );
    } catch (e, st) {
      log('updateProfile error', error: e, stackTrace: st);
      return const Left(ProfileFailure('Error de red'));
    }
  }

  /// Decodifica el `sub` del JWT (mismo patrón que en
  /// `RemoteOrderTrackingRepository`).
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
}
