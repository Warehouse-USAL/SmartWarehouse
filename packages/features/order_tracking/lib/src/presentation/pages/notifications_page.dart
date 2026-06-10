import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = Injector.i.resolve<OrderNotificationCubit>();
    // Al abrir la página marcamos todas como leídas. Una microtask para no
    // emitir durante build.
    Future.microtask(cubit.markAllAsRead);
    return Scaffold(
      backgroundColor: SwColors.white,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text('Notificaciones', style: SwText.display(size: 22)),
        leading: const BackButton(color: SwColors.text),
      ),
      body: BlocBuilder<OrderNotificationCubit, OrderNotificationState>(
        bloc: cubit,
        builder: (context, state) {
          if (state.notifications.isEmpty) {
            return const SwEmptyView(
              title: 'Sin notificaciones',
              message: 'Las actualizaciones de tus órdenes aparecerán acá.',
              icon: Icons.notifications_off_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: SwColors.border),
            itemBuilder: (context, index) {
              final n = state.notifications[index];
              return _NotificationTile(
                notification: n,
                onTap: () {
                  Injector.i.resolve<NavigationHelper>().pushNamed(
                        context,
                        routeName: Routes.orderDetail(n.change.orderId),
                      );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final OrderNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = notification.change;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SwColors.yellowSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: SwColors.yellowDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orden ${c.orderId}',
                    style: SwText.body(size: 14, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_statusLabel(c.oldStatus)} → ${_statusLabel(c.newStatus)}',
                    style: SwText.body(size: 13, color: SwColors.text2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(notification.receivedAt),
                    style: SwText.body(size: 11, color: SwColors.text3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SwColors.text3),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'Pendiente',
        OrderStatus.inProgress => 'En progreso',
        OrderStatus.completed => 'Completado',
        OrderStatus.cancelled => 'Cancelado',
      };

  String _relativeTime(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }
}
