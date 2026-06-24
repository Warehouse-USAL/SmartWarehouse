import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/data/repositories/mock_profile_repository.dart';
import 'package:profile/src/data/repositories/remote_profile_repository.dart';
import 'package:profile/src/domain/repositories/profile_repository.dart';
import 'package:profile/src/presentation/bloc/profile_cubit.dart';
import 'package:profile/src/presentation/pages/edit_address_page.dart';
import 'package:profile/src/presentation/pages/profile_page.dart';
import 'package:profile/src/presentation/widgets/checkout_address_sheet.dart';

class ProfileFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<ProfileRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockProfileRepository()
            : RemoteProfileRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                orderTrackingRepository:
                    Injector.i.resolve<OrderTrackingRepository>(),
                catalogRepository: Injector.i.resolve<CatalogRepository>(),
              ),
      )
      ..registerLazySingleton<ProfileCubit>(
        () => ProfileCubit(Injector.i.resolve<ProfileRepository>()),
      );
  }

  static Widget buildProfilePage() {
    return ProfilePage(cubit: Injector.i.resolve<ProfileCubit>());
  }

  /// Página dedicada a editar (o agregar por primera vez) la dirección de
  /// entrega. Wireada al route `Routes.profileEditAddress`.
  static Widget buildEditAddressPage() {
    return EditAddressPage(cubit: Injector.i.resolve<ProfileCubit>());
  }

  /// Abre el sheet de confirmación de entrega (usado en el cart checkout).
  /// Pre-popula con el address del perfil si existe. Si el usuario tickea
  /// "Guardar en mi perfil", llama internamente `PATCH /users/me` antes de
  /// devolver. Devuelve `null` si el usuario cancela.
  static Future<CheckoutAddressResult?> collectCheckoutAddress(
    BuildContext context,
  ) async {
    final cubit = Injector.i.resolve<ProfileCubit>();
    // El cubit es singleton — si el usuario nunca abrió el tab de Perfil,
    // sigue en Loading y `state.user.address` no existe. Forzamos load()
    // antes de leer el address, así el form se autocompleta con lo
    // guardado en el back.
    if (cubit.state is! ProfileReady) {
      await cubit.load();
    }
    if (!context.mounted) return null;
    final state = cubit.state;
    final initial = state is ProfileReady ? state.user.address : null;
    final result = await showModalBottomSheet<CheckoutAddressResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => CheckoutAddressSheet(initialAddress: initial),
    );
    if (result == null) return null;
    if (result.saveToProfile) {
      // Fire and await — si falla, no abortamos la orden: igual la creamos
      // con el address del form, solo no quedó persistido al perfil.
      await cubit.updateProfile(address: result.address);
    }
    return result;
  }
}
