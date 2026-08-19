import 'package:catalog/catalog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/src/domain/entities/order_summary.dart';
import 'package:profile/src/domain/entities/profile_user.dart';
import 'package:profile/src/domain/entities/user_address.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileLoading());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());

    final results = await Future.wait([
      _repository.getProfile(),
      _repository.getOrderHistory(),
    ]);
    if (isClosed) return;

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
          final composed = _composeStats(user as ProfileUser, list);
          emit(ProfileReady(user: composed, orders: list));
        },
      ),
    );
  }

  /// Llama `PATCH /users/me` con los campos nuevos (name y/o address) y
  /// actualiza el estado con el ProfileUser devuelto por el back.
  Future<bool> updateProfile({String? name, UserAddress? address}) async {
    final current = state;
    if (current is! ProfileReady) return false;
    final result = await _repository.updateProfile(
      name: name,
      address: address,
    );
    if (isClosed) return false;
    return result.fold(
      (_) => false,
      (updated) {
        final composed = _composeStats(updated, current.orders);
        emit(ProfileReady(user: composed, orders: current.orders));
        return true;
      },
    );
  }

  ProfileUser _composeStats(ProfileUser user, List<OrderSummary> orders) {
    final open = orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .length;
    // "Gastado este mes": solo órdenes del mes en curso, y solo si todas
    // tienen total confiable en la misma moneda. Si no, null → "—".
    final now = DateTime.now();
    Money? spent;
    var reliable = true;
    for (final o in orders) {
      final created = o.createdAt;
      if (created == null ||
          created.year != now.year ||
          created.month != now.month) {
        continue;
      }
      final total = o.total;
      if (total == null || (spent != null && total.currency != spent.currency)) {
        reliable = false;
        break;
      }
      spent = spent == null ? total : spent + total;
    }
    return user.copyWith(
      openOrdersCount: open,
      spentThisMonth: reliable ? spent : null,
      clearSpent: !reliable,
    );
  }
}
