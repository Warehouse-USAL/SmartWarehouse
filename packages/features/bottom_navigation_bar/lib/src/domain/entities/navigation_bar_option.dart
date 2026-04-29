import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_bar_option.freezed.dart';

@freezed
sealed class NavigationBarOption with _$NavigationBarOption {
  const NavigationBarOption._();

  const factory NavigationBarOption.home() = HomeNavigationBarOption;

  // TODO: Add more navigation bar options as needed
  // Example:
  // const factory NavigationBarOption.orders() = OrdersNavigationBarOption;

  bool get isHome => maybeWhen(home: () => true, orElse: () => false);

  // TODO: Add getters for new navigation bar options
}
