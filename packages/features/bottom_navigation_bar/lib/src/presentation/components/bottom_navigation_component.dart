import 'package:bottom_navigation_bar/src/domain/entities/navigation_bar_option.dart';
import 'package:cart/cart.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavigationComponent extends StatelessWidget {
  const BottomNavigationComponent({
    required this.selectedTab,
    required this.onItemPressed,
    super.key,
  });

  final Function(BuildContext context, NavigationBarOption option) onItemPressed;
  final NavigationBarOption selectedTab;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, Cart>(
      bloc: CartFeatureBuilder.cartCubit(),
      builder: (context, cart) {
        final tabs = <SwNavTab>[
          const SwNavTab(id: 'products', label: 'Catálogo', icon: Icons.inventory_2_outlined),
          SwNavTab(id: 'cart', label: 'Carrito', icon: Icons.shopping_cart_outlined, badgeCount: cart.itemCount),
        const SwNavTab(id: 'profile', label: 'Profile', icon: Icons.person_outline),
        ];
        final activeId = selectedTab.when(
          profile: () => 'home',
          products: () => 'products',
          cart: () => 'cart',
        );
        return SwBottomNav(
          tabs: tabs,
          activeId: activeId,
          onTabSelected: (id) {
            final option = switch (id) {
              'profile' => const NavigationBarOption.profile(),
              'products' => const NavigationBarOption.products(),
              'cart' => const NavigationBarOption.cart(),
              _ => const NavigationBarOption.products(),
            };
            onItemPressed(context, option);
          },
        );
      },
    );
  }
}
