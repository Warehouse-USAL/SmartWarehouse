import 'package:dartz/dartz.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_address.dart';

abstract class ProfileRepository {
  Future<Either<ProfileFailure, ProfileUser>> getProfile();

  Future<Either<ProfileFailure, List<OrderSummary>>> getOrderHistory();

  /// `PATCH /users/me` — update parcial del perfil propio. Cualquier campo
  /// `null` se omite del body.
  Future<Either<ProfileFailure, ProfileUser>> updateProfile({
    String? name,
    UserAddress? address,
  });
}

class ProfileFailure {
  const ProfileFailure([this.message]);
  final String? message;
}
