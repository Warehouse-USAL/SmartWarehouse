import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:order_tracking/src/data/repositories/mock_order_tracking_repository.dart';
import 'package:order_tracking/src/data/repositories/remote_order_tracking_repository.dart';
import 'package:order_tracking/src/presentation/pages/notifications_page.dart';
import 'package:order_tracking/src/presentation/pages/order_detail_page.dart';
import 'package:order_tracking/src/presentation/pages/order_list_page.dart';
import 'package:order_tracking/src/presentation/widgets/notification_bell.dart';

class OrderTrackingFeatureBuilder {
  /// Key global del ScaffoldMessenger — `application.dart` la pasa a
  /// `MaterialApp.router(scaffoldMessengerKey: ...)`. La usamos para mostrar
  /// SnackBars de notificaciones de WS desde afuera del árbol del Navigator
  /// (lo que evita los asserts de `_RouteEntry.markForComplete` que pasaban
  /// con un BlocListener envolviendo el Navigator).
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void injectDependencies({required String baseUrl}) {
    Injector.i
      ..registerLazySingleton<OrderTrackingRepository>(
        () => Injector.i.resolve<AppDataSource>().isMock
            ? MockOrderTrackingRepository()
            : RemoteOrderTrackingRepository(
                httpHelper: Injector.i.resolve<HttpHelper>(),
                getToken: OnGetTokenUseCase.call,
                baseUrl: baseUrl,
                historyStore: Injector.i.resolve<OrderHistoryStore>(),
              ),
      )
      ..registerLazySingleton<OrderListCubit>(
        () => OrderListCubit(Injector.i.resolve<OrderTrackingRepository>()),
      )
      ..registerSingleton<OrderNotificationCubit>(
        OrderNotificationCubit(
          Injector.i.resolve<OrderTrackingRepository>(),
          onEvent: _showOrderSnackBar,
        ),
      );
  }

  /// Call once after the user authenticates to start the global WS listener.
  static void startNotifications() =>
      Injector.i.resolve<OrderNotificationCubit>().start();

  /// Icono de campana con badge — usar en app bars donde quiera mostrarse
  /// el indicador de notificaciones pendientes.
  static Widget buildNotificationBell() => const NotificationBell();

  /// Página `/notifications` con el historial de notificaciones de la sesión.
  static Widget buildNotificationsPage() => const NotificationsPage();

  /// Llamada por el OrderNotificationCubit cuando llega un order.updated
  /// del WS. Muestra una SnackBar a través del scaffoldMessengerKey global —
  /// no depende del árbol de widgets, así que se puede llamar de cualquier
  /// rincón sin tocar el navigator.
  static void _showOrderSnackBar(OrderStatusChange change) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final orderId = change.orderId;
    final newStatus = change.newStatus;
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
          onPressed: () {
            final ctx = scaffoldMessengerKey.currentContext;
            if (ctx == null) return;
            Injector.i.resolve<NavigationHelper>().pushNamed(
                  ctx,
                  routeName: Routes.orderDetail(orderId),
                );
          },
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
    final cubit = OrderDetailCubit(
      Injector.i.resolve<OrderTrackingRepository>(),
      Injector.i.resolve<CatalogRepository>(),
    )..load(orderId);
    return OrderDetailPage(cubit: cubit, orderId: orderId);
  }
}
