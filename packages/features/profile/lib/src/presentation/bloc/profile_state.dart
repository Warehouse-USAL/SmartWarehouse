import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_location.dart';

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
    this.location,
  });

  final ProfileUser user;
  final List<OrderSummary> orders;
  final UserLocation? location;

  ProfileReady copyWith({
    ProfileUser? user,
    List<OrderSummary>? orders,
    UserLocation? location,
  }) =>
      ProfileReady(
        user: user ?? this.user,
        orders: orders ?? this.orders,
        location: location ?? this.location,
      );
}
