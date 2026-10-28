import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_chip.dart';
import 'package:order_tracking/src/presentation/widgets/order_status_timeline.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    required this.cubit,
    required this.orderId,
    super.key,
  });

  final OrderDetailCubit cubit;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailCubit, OrderDetailState>(
      bloc: cubit,
      builder: (context, state) {
        final placedDate = state is OrderDetailReady
            ? _formatDate(state.order.createdAt)
            : null;

        return BottomNavigationBarFeatureBuilder.buildScaffold(
          context,
          selectedTab: const NavigationBarOption.orders(),
          scrollable: false,
          appBar: AppBar(
            backgroundColor: SwColors.white,
            elevation: 0,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Orden $orderId', style: SwText.display(size: 18)),
                if (placedDate != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Realizado $placedDate',
                    style: SwText.body(size: 11, color: SwColors.text3),
                  ),
                ],
              ],
            ),
          ),
          child: switch (state) {
            OrderDetailLoading() => const Center(child: SwLoadingSpinner()),
            OrderDetailError(:final message) => SwErrorView(
              message: message,
              onRetry: () => cubit.load(orderId),
            ),
            OrderDetailReady(:final order, :final items) => RefreshIndicator(
              color: SwColors.yellow,
              onRefresh: () async => cubit.load(orderId),
              child: _DetailContent(order: order, items: items, cubit: cubit),
            ),
          },
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.order,
    required this.items,
    required this.cubit,
  });

  final Order order;
  final List<OrderItemDetail> items;
  final OrderDetailCubit cubit;

  Future<void> _onCancelPressed(BuildContext context) async {
    final confirmed = await SwDialog.show(
      context,
      title: '¿Cancelar la orden?',
      message:
          'La orden ${order.id} se va a cancelar y los vehículos van a '
          'devolver los productos. Esta acción no se puede deshacer.',
      confirmLabel: 'Sí, cancelar orden',
      cancelLabel: 'Volver',
      destructive: true,
      confirmKey: E2eKeys.orderCancelConfirm,
    );
    if (!confirmed || !context.mounted) return;
    final error = await cubit.cancel(order.id);
    if (!context.mounted) return;
    if (error == null) {
      final state = cubit.state;
      final cancellationPending =
          state is OrderDetailReady &&
          state.order.status == OrderStatus.inProgress &&
          state.order.cancellationRequestedAt != null;
      SwSnackBar.show(
        context,
        message: cancellationPending
            ? 'Cancelación de la orden ${order.id} solicitada'
            : 'Orden ${order.id} cancelada',
        detail: cancellationPending
            ? 'Los vehículos actualizarán el estado cuando devuelvan los productos.'
            : null,
        icon: Icons.check_circle_outline,
      );
    } else {
      SwSnackBar.showError(context, message: error);
    }
  }

  void _onReorderPressed(BuildContext context) {
    final plan = buildReorderPlan(items);
    if (plan.isEmpty) {
      SwSnackBar.showError(
        context,
        message: 'Ninguno de los productos está disponible hoy',
        detail: 'Revisá el catálogo para alternativas',
      );
      return;
    }
    // El agregado al carrito y la navegación los cablea la capa de
    // aplicación (order_tracking no depende de cart) — mismo patrón que
    // onOpenOrder del snackbar de notificaciones.
    OrderTrackingFeatureBuilder.onReorder?.call(plan.entries);
    final omittedDetail = plan.omitted.isNotEmpty
        ? '${plan.omitted.join(', ')} sin stock — quedó afuera'
        : plan.adjusted > 0
        ? 'Algunas cantidades se ajustaron al stock actual'
        : null;
    SwSnackBar.show(
      context,
      message:
          '${plan.entries.length} '
          '${plan.entries.length == 1 ? 'producto agregado' : 'productos agregados'} '
          'al pedido',
      detail: omittedDetail,
      icon: Icons.shopping_cart_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estado', style: SwText.display(size: 18)),
              OrderStatusChip(status: order.status),
            ],
          ),
        ),
        if (order.status == OrderStatus.inProgress &&
            order.cancellationRequestedAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SwCard(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Cancelación solicitada. El estado se actualizará cuando los vehículos devuelvan los productos.',
                style: SwText.body(size: 14, color: SwColors.text3),
              ),
            ),
          ),
        SwCard(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
          child: OrderStatusTimeline(status: order.status),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text('Detalles del pedido', style: SwText.display(size: 18)),
        ),
        SwCard(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Sin ítems',
                    style: SwText.body(size: 14, color: SwColors.text3),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      _ItemRow(detail: items[i]),
                      if (i < items.length - 1)
                        const Divider(height: 1, color: SwColors.border),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 18),
        if (order.status.canReorder && items.isNotEmpty)
          SwButton(
            key: E2eKeys.orderReorderButton,
            label: 'Pedir de nuevo',
            icon: Icons.replay_rounded,
            onPressed: () => _onReorderPressed(context),
          ),
        if (order.status.isCancellable &&
            order.cancellationRequestedAt == null) ...[
          if (order.status.canReorder && items.isNotEmpty)
            const SizedBox(height: 8),
          SwButton(
            key: E2eKeys.orderCancelButton,
            label: 'Cancelar orden',
            variant: SwButtonVariant.dangerGhost,
            onPressed: () => _onCancelPressed(context),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.detail});

  final OrderItemDetail detail;

  @override
  Widget build(BuildContext context) {
    final imageUrl = detail.imageUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: imageUrl == null || imageUrl.isEmpty
                  ? CustomPaint(
                      size: const Size(48, 48),
                      painter: _StripedPlaceholderPainter(),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CustomPaint(
                        size: const Size(48, 48),
                        painter: _StripedPlaceholderPainter(),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: SwText.body(size: 14, weight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU ${detail.item.productId.substring(detail.item.productId.length > 8 ? detail.item.productId.length - 8 : 0)} · cant. ${detail.item.quantity}',
                  style: SwText.body(size: 12, color: SwColors.text3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            // Subtotal en cero = precio no hidratado: "—" en vez de un $0.
            detail.subtotal.amount > 0 ? detail.subtotal.formatted : '—',
            style: SwText.body(size: 14, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StripedPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = SwColors.surfaceAlt;
    canvas.drawRect(Offset.zero & size, bg);

    final stripe = Paint()
      ..color = SwColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const step = 8.0;
    for (double i = -size.height; i < size.width + size.height; i += step) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_StripedPlaceholderPainter oldDelegate) => false;
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dtDay = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(dtDay).inDays;
  final time =
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  if (diff == 0) return 'Hoy, $time';
  if (diff == 1) return 'Ayer, $time';
  return '${dt.day}/${dt.month}/${dt.year}';
}
