import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:commons/commons.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:order_tracking/order_tracking.dart';
import 'package:profile/src/data/dtos/user_dto.dart';
import 'package:profile/src/data/mappers/profile_mapper.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
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
  });

  final HttpHelper httpHelper;
  final String? Function() getToken;
  final OrderTrackingRepository orderTrackingRepository;

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
      return result.fold(
        (failure) => Left(ProfileFailure(failure.message ?? 'Error obteniendo órdenes')),
        (orders) => Right(orders.map((o) => o.toSummary()).toList(growable: false)),
      );
    } catch (e, st) {
      log('getOrderHistory error', error: e, stackTrace: st);
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
