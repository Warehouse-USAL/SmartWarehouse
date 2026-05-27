import 'package:cart/src/presentation/widgets/cart_item_tile.dart';
import 'package:cart/src/presentation/widgets/create_order_confirmation_dialog.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({required this.cartCubit, required this.createOrderCubit, super.key});

  final CartCubit cartCubit;
  final CreateOrderCubit createOrderCubit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwColors.white,
      bottomNavigationBar:
          BottomNavigationBarFeatureBuilder.build(context, const NavigationBarOption.cart()),
      body: SafeArea(
        bottom: false,
        child: BlocListener<CreateOrderCubit, CreateOrderState>(
          bloc: createOrderCubit,
          listener: (ctx, state) => _onOrderStateChanged(ctx, state),
          child: BlocBuilder<CartCubit, Cart>(
            bloc: cartCubit,
            builder: (context, cart) {
              return Column(
                children: [
                  _CartAppBar(),
                  Expanded(
                    child: cart.isEmpty
                        ? _EmptyView(onContinue: () => _goCatalog(context))
                        : _CartBody(
                            cart: cart,
                            onQty: cartCubit.updateQuantity,
                            onRemove: cartCubit.remove,
                          ),
                  ),
                  if (cart.isNotEmpty)
                    _Footer(
                      cart: cart,
                      onConfirm: () => _onCreateOrderPressed(context, cart),
                      onContinue: () => _goCatalog(context),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onCreateOrderPressed(BuildContext context, Cart cart) async {
    final invalid = cart.items.any((i) {
      final available = i.product.stock.available;
      return i.quantity <= 0 || i.quantity > available;
    });
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay items con cantidad inválida o sin stock')),
      );
      return;
    }
    final confirmed = await CreateOrderConfirmationDialog.show(context, cart);
    if (!confirmed) return;
    await createOrderCubit.submit(
      items: _toOrderItems(cart),
      destination: OrderDestination.defaults,
    );
  }

  void _onOrderStateChanged(BuildContext context, CreateOrderState state) {
    switch (state) {
      case CreateOrderSuccess(:final order):
        cartCubit.clear();
        createOrderCubit.reset();
        Injector.i.resolve<NavigationHelper>().pushNamed(
              context,
              routeName: Routes.orderSuccess(order.id),
              replace: true,
            );
      case CreateOrderFailure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => createOrderCubit.submit(
                items: _toOrderItems(cartCubit.state),
                destination: OrderDestination.defaults,
              ),
            ),
          ),
        );
      case CreateOrderIdle():
      case CreateOrderSubmitting():
        break;
    }
  }

  List<OrderItem> _toOrderItems(Cart cart) {
    return cart.items
        .map((i) => OrderItem(
              productId: i.product.id,
              productName: i.product.name,
              unitPrice: i.product.price,
              quantity: i.quantity,
            ))
        .toList();
  }

  void _goCatalog(BuildContext context) {
    Injector.i.resolve<NavigationHelper>().pushNamed(context, routeName: Routes.catalog);
  }
}

class _CartAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Center(child: Text('Tu pedido', style: SwText.display(size: 20))),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 48, color: SwColors.text3),
            const SizedBox(height: 12),
            Text('Tu pedido está vacío', style: SwText.body(size: 14, color: SwColors.text3)),
            const SizedBox(height: 16),
            SizedBox(
              width: 220,
              child: SwButton(
                label: 'Ir al catálogo',
                variant: SwButtonVariant.secondary,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.cart, required this.onQty, required this.onRemove});

  final Cart cart;
  final void Function(String productId, int quantity) onQty;
  final void Function(String productId) onRemove;

  @override
  Widget build(BuildContext context) {
    final total = cart.total;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading('Productos · ${cart.items.length}'),
          SwCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  for (final (idx, item) in cart.items.indexed)
                    Container(
                      decoration: BoxDecoration(
                        border: idx < cart.items.length - 1
                            ? const Border(bottom: BorderSide(color: SwColors.border))
                            : null,
                      ),
                      child: CartItemTile(
                        item: item,
                        onQuantityChanged: (q) => onQty(item.product.id, q),
                        onRemove: () => onRemove(item.product.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Bloque "Destino" oculto por ahora — el destination se sigue
          // derivando de las ubicaciones para mandarlo al backend, pero no se
          // muestra en la UI.
          if (total != null) ...[
            _SectionHeading('Resumen'),
            SwCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _SummaryRow('Unidades', '${cart.itemCount}'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: SwText.body(size: 15, weight: FontWeight.w700)),
                          Text(total.formatted, style: SwText.display(size: 22)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
      child: Text(text, style: SwText.display(size: 18, letterSpacing: -0.01)),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SwColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: SwText.body(size: 14, color: SwColors.text3))),
          Text(value, style: SwText.body(size: 14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.cart, required this.onConfirm, required this.onContinue});
  final Cart cart;
  final VoidCallback onConfirm;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final total = cart.total;
    final label = total == null ? 'Confirmar pedido' : 'Confirmar pedido · ${total.formatted}';
    return Container(
      decoration: const BoxDecoration(
        color: SwColors.white,
        border: Border(top: BorderSide(color: SwColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          SwButton(
            label: label,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onContinue,
            child: Text('Seguir comprando', style: SwText.body(size: 14, color: SwColors.link)),
          ),
        ],
      ),
    );
  }
}
