import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:profile/src/data/repositories/mock_profile_repository.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_cubit.dart';
import 'package:profile/src/presentation/pages/profile_page.dart';

class ProfileFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<ProfileRepository>(
        MockProfileRepository.new,
      )
      ..registerLazySingleton<ProfileCubit>(
        () => ProfileCubit(Injector.i.resolve<ProfileRepository>()),
      );
  }

  static Widget buildProfilePage() {
    return ProfilePage(cubit: Injector.i.resolve<ProfileCubit>());
  }
}
