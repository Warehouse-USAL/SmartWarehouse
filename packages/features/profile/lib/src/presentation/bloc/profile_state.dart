import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

class ProfileReady extends ProfileState {
  const ProfileReady({
    required this.user,
    required this.orders,
  });

  final ProfileUser user;
  final List<OrderSummary> orders;
}
