import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_bar_option.freezed.dart';

@freezed
sealed class NavigationBarOption with _$NavigationBarOption {
  const NavigationBarOption._();

  const factory NavigationBarOption.products() = ProductsNavigationBarOption;

  const factory NavigationBarOption.cart() = CartNavigationBarOption;

  const factory NavigationBarOption.orders() = OrdersNavigationBarOption;

  const factory NavigationBarOption.profile() = ProfileNavigationBarOption;

  bool get isProducts => maybeWhen(products: () => true, orElse: () => false);

  bool get isCart => maybeWhen(cart: () => true, orElse: () => false);

  bool get isOrders => maybeWhen(orders: () => true, orElse: () => false);

  bool get isProfile => maybeWhen(profile: () => true, orElse: () => false);
}
