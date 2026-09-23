import 'package:cart/src/data/repositories/in_memory_cart_repository.dart';
import 'package:cart/src/domain/repositories/cart_repository.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:cart/src/presentation/pages/cart_page.dart';
import 'package:cart/src/presentation/widgets/cart_badge.dart';
import 'package:catalog/catalog.dart';
import 'package:commons/helpers/injector/injector.dart';
import 'package:flutter/widgets.dart';
import 'package:orders/orders.dart';

class CartFeatureBuilder {
  static void injectDependencies() {
    Injector.i
      ..registerLazySingleton<CartRepository>(InMemoryCartRepository.new)
      ..registerLazySingleton<CartCubit>(
        // El catálogo se resuelve defensivo: en la app siempre está, pero
        // los harnesses de test de otras features inyectan el cart solo y
        // el cubit debe funcionar (sin revalidación) igual.
        () => CartCubit(
          Injector.i.resolve<CartRepository>(),
          catalogRepository: Injector.i.isRegistered<CatalogRepository>()
              ? Injector.i.resolve<CatalogRepository>()
              : null,
        ),
      );
  }

  static void addToCart(Product product, {int quantity = 1}) {
    Injector.i.resolve<CartCubit>().add(product, quantity: quantity);
  }

  static CartCubit cartCubit() => Injector.i.resolve<CartCubit>();

  /// Limpieza de sesión en logout: el carrito es estado del usuario — si
  /// entra otro usuario en este device no tiene que encontrarse los items
  /// del anterior.
  static void onLogout() => Injector.i.resolve<CartCubit>().clear();

  static Widget buildCartPage() {
    return CartPage(
      cartCubit: Injector.i.resolve<CartCubit>(),
      createOrderCubit: Injector.i.resolve<CreateOrderCubit>(),
    );
  }

  static Widget buildBadge({required Widget child}) {
    return CartBadge(cubit: Injector.i.resolve<CartCubit>(), child: child);
  }
}
