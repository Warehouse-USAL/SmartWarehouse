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
        () => CartCubit(
          Injector.i.resolve<CartRepository>(),
          catalogRepository: Injector.i.resolve<CatalogRepository>(),
        ),
      );
  }

  static void addToCart(Product product, {int quantity = 1}) {
    Injector.i.resolve<CartCubit>().add(product, quantity: quantity);
  }

  static CartCubit cartCubit() => Injector.i.resolve<CartCubit>();

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
