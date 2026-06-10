import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_state.dart';

export 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileLoading());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());

    final profileResult = await _repository.getProfile();
    final ordersResult = await _repository.getOrderHistory();

    profileResult.fold(
      (failure) => emit(ProfileError(failure.message ?? 'Error al cargar el perfil')),
      (user) => ordersResult.fold(
        (failure) => emit(ProfileError(failure.message ?? 'Error al cargar los pedidos')),
        (orders) => emit(ProfileReady(user: user, orders: orders)),
      ),
    );
  }
}
