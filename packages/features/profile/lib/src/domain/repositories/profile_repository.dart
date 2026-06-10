import 'package:dartz/dartz.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';

abstract class ProfileRepository {
  Future<Either<ProfileFailure, ProfileUser>> getProfile();
  Future<Either<ProfileFailure, List<OrderSummary>>> getOrderHistory();
}

class ProfileFailure {
  const ProfileFailure([this.message]);
  final String? message;
}
