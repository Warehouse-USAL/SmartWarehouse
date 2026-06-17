import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/data/repositories/mock_profile_repository.dart';
import 'package:profile/src/data/repositories/remote_profile_repository.dart';
import 'package:profile/src/data/storage/user_location_store.dart';
import 'package:profile/src/domain/entities/user_location.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_cubit.dart';
import 'package:profile/src/presentation/pages/profile_page.dart';
import 'package:profile/src/presentation/widgets/location_form_sheet.dart';

class ProfileFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<UserLocationStore>(
        () => HiveUserLocationStore(Injector.i.resolve<PersistenceHelper>()),
      )
      ..registerLazySingleton<ProfileRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockProfileRepository()
            : RemoteProfileRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                orderTrackingRepository:
                    Injector.i.resolve<OrderTrackingRepository>(),
              ),
      )
      ..registerLazySingleton<ProfileCubit>(
        () => ProfileCubit(
          Injector.i.resolve<ProfileRepository>(),
          Injector.i.resolve<UserLocationStore>(),
        ),
      );
  }

  static Widget buildProfilePage() {
    return ProfilePage(cubit: Injector.i.resolve<ProfileCubit>());
  }

  /// Devuelve la ubicación guardada del usuario; si no hay, abre el form
  /// sheet para que la configure (al guardar también la persiste). Si el
  /// usuario cancela el sheet, devuelve null.
  ///
  /// Usado en el cart checkout para no tener que crear UI de address ahí
  /// y mantener la lógica de persistencia en un solo lado.
  static Future<UserLocation?> getOrPromptLocation(BuildContext context) async {
    final store = Injector.i.resolve<UserLocationStore>();
    final saved = await store.get();
    if (saved != null) return saved;
    if (!context.mounted) return null;
    final result = await showModalBottomSheet<UserLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const LocationFormSheet(initial: null),
    );
    if (result == null) return null;
    await store.save(result);
    // Si la pantalla de perfil está abierta, refresca su estado al volver.
    final profileCubit = Injector.i.resolve<ProfileCubit>();
    await profileCubit.saveLocation(result);
    return result;
  }
}
