import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/presentation/bloc/cart_cubit.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Contador de items del pedido superpuesto al ícono del carrito. Usa el
/// [SwBadge] del design system (pill amarilla de marca) en lugar del rojo
/// Material que tenía antes.
class CartBadge extends StatelessWidget {
  const CartBadge({required this.cubit, required this.child, super.key});

  final CartCubit cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, Cart>(
      bloc: cubit,
      builder: (context, cart) {
        if (cart.itemCount == 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -4,
              right: -4,
              child: SwBadge(count: cart.itemCount),
            ),
          ],
        );
      },
    );
  }
}
