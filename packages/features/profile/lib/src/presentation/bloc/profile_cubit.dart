import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/src/data/storage/user_location_store.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_location.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._locationStore)
      : super(const ProfileLoading());

  final ProfileRepository _repository;
  final UserLocationStore _locationStore;

  Future<void> load() async {
    emit(const ProfileLoading());

    final results = await Future.wait([
      _repository.getProfile(),
      _repository.getOrderHistory(),
      _locationStore.get(),
    ]);

    final profileResult = results[0] as dynamic;
    final ordersResult = results[1] as dynamic;
    final location = results[2] as UserLocation?;

    profileResult.fold(
      (failure) =>
          emit(ProfileError(failure.message ?? 'Error al cargar el perfil')),
      (user) => ordersResult.fold(
        (failure) =>
            emit(ProfileError(failure.message ?? 'Error al cargar los pedidos')),
        (orders) {
          final list = orders as List<OrderSummary>;
          final composed = _composeStats(user as ProfileUser, list, location);
          emit(ProfileReady(user: composed, orders: list, location: location));
        },
      ),
    );
  }

  /// Persiste la ubicación y re-emite el ready con el nuevo valor.
  Future<void> saveLocation(UserLocation location) async {
    await _locationStore.save(location);
    final current = state;
    if (current is ProfileReady) {
      final updatedUser = current.user.copyWith(bay: location.destinationArea);
      emit(current.copyWith(user: updatedUser, location: location));
    }
  }

  /// Compone stats derivados de la lista de órdenes + la ubicación guardada
  /// (para el badge del role). El back no expone bay/openOrdersCount/spent.
  ProfileUser _composeStats(
    ProfileUser user,
    List<OrderSummary> orders,
    UserLocation? location,
  ) {
    final open = orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .length;
    final spent = orders.fold<double>(0, (s, o) => s + o.totalAmount);
    return ProfileUser(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      bay: location?.destinationArea ?? user.bay,
      openOrdersCount: open,
      spentThisMonth: spent > 0 ? spent : user.spentThisMonth,
    );
  }
}
