import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileLoading());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());

    // En paralelo para latencia.
    final results = await Future.wait([
      _repository.getProfile(),
      _repository.getOrderHistory(),
    ]);

    final profileResult = results[0] as dynamic;
    final ordersResult = results[1] as dynamic;

    profileResult.fold(
      (failure) =>
          emit(ProfileError(failure.message ?? 'Error al cargar el perfil')),
      (user) => ordersResult.fold(
        (failure) =>
            emit(ProfileError(failure.message ?? 'Error al cargar los pedidos')),
        (orders) {
          final list = orders as List<OrderSummary>;
          // Componemos el ProfileUser final con los stats derivados de las
          // órdenes (el back no los expone) en vez de los defaults del DTO.
          final composed = _composeStats(user as ProfileUser, list);
          emit(ProfileReady(user: composed, orders: list));
        },
      ),
    );
  }

  /// Sobrescribe `openOrdersCount` y `spentThisMonth` con valores derivados
  /// de la lista de órdenes que ya tenemos. El back no expone agregados por
  /// usuario, así que los calculamos client-side.
  ProfileUser _composeStats(ProfileUser user, List<OrderSummary> orders) {
    final open = orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .length;
    // OrderSummary.dateLabel es "Mes Día" sin año. Como el total ya viene
    // como 0 mientras el item no tenga precio del back, sumar siempre da 0.
    // Lo dejamos preparado para cuando el back exponga precios.
    final spent = orders.fold<double>(0, (s, o) => s + o.totalAmount);
    return ProfileUser(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      bay: user.bay,
      openOrdersCount: open,
      spentThisMonth: spent > 0 ? spent : user.spentThisMonth,
    );
    // ignore: dead_code
  }
}
