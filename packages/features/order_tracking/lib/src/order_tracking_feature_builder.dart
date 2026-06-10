import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/pages/notifications_page.dart';
import 'package:order_tracking/src/presentation/pages/order_detail_page.dart';
import 'package:order_tracking/src/presentation/pages/order_list_page.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';

class OrderTrackingFeatureBuilder {
  static void injectDependencies({required String baseUrl}) {
    Injector.i
      ..registerLazySingleton<OrderTrackingRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockOrderTrackingRepository()
            : RemoteOrderTrackingRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                baseUrl: baseUrl,
              ),
      )
      ..registerLazySingleton<OrderListCubit>(
        () => OrderListCubit(Injector.i.resolve<OrderTrackingRepository>()),
      )
      ..registerSingleton<OrderNotificationCubit>(
        OrderNotificationCubit(Injector.i.resolve<OrderTrackingRepository>()),
      );
  }

  /// Call once after the user authenticates to start the global WS listener.
  static void startNotifications() =>
      Injector.i.resolve<OrderNotificationCubit>().start();

  /// Wrap the app's navigator child (inside MaterialApp builder:) with the
  /// in-app notification listener. Must be inside MaterialApp so
  /// ScaffoldMessenger is available.
  static Widget buildNotificationListener({required Widget child}) {
    return BlocListener<OrderNotificationCubit, OrderNotificationState>(
      bloc: Injector.i.resolve<OrderNotificationCubit>(),
      // Solo disparar SnackBar cuando llega una notificación nueva
      // (lastReceived cambia), no cuando se marcan como leídas.
      listenWhen: (prev, curr) =>
          curr.lastReceived != null && prev.lastReceived != curr.lastReceived,
      listener: (ctx, state) {
        final received = state.lastReceived;
        if (received != null) {
          _showOrderNotification(ctx, received.change);
        }
      },
      child: child,
    );
  }

  /// Icono de campana con badge — usar en app bars donde quiera mostrarse
  /// el indicador de notificaciones pendientes.
  static Widget buildNotificationBell() => const NotificationBell();

  /// Página `/notifications` con el historial de notificaciones de la sesión.
  static Widget buildNotificationsPage() => const NotificationsPage();

  static void _showOrderNotification(
    BuildContext context,
    OrderStatusChange change,
  ) {
    final orderId = change.orderId;
    final newStatus = change.newStatus;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SwColors.text,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: SwColors.yellowSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: SwColors.yellowDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderId,
                    style: SwText.body(
                      size: 13,
                      weight: FontWeight.w600,
                      color: SwColors.white,
                    ),
                  ),
                  Text(
                    _statusLabel(newStatus),
                    style: SwText.body(size: 11, color: SwColors.yellow),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Ver',
          textColor: SwColors.yellow,
          onPressed: () => Injector.i
              .resolve<NavigationHelper>()
              .pushNamed(context, routeName: Routes.orderDetail(orderId)),
        ),
      ),
    );
  }

  static String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pending => 'Pendiente',
        OrderStatus.inProgress => 'En progreso',
        OrderStatus.completed => 'Completado',
        OrderStatus.cancelled => 'Cancelado',
      };

  static Widget buildOrderListPage() =>
      OrderListPage(cubit: Injector.i.resolve<OrderListCubit>());

  static Widget buildOrderDetailPage(String orderId) {
    final cubit =
        OrderDetailCubit(Injector.i.resolve<OrderTrackingRepository>())
          ..load(orderId);
    return OrderDetailPage(cubit: cubit, orderId: orderId);
  }
}
