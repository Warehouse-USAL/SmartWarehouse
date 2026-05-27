import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_bar_option.freezed.dart';

@freezed
sealed class NavigationBarOption with _$NavigationBarOption {
  const NavigationBarOption._();

  const factory NavigationBarOption.profile() = ProfileNavigationBarOption;

  const factory NavigationBarOption.products() = ProductsNavigationBarOption;

  const factory NavigationBarOption.cart() = CartNavigationBarOption;

  bool get isProfile => maybeWhen(profile: () => true, orElse: () => false);

  bool get isProducts => maybeWhen(products: () => true, orElse: () => false);

  bool get isCart => maybeWhen(cart: () => true, orElse: () => false);
}
