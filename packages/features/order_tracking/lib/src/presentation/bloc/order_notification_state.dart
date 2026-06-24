import 'package:order_tracking/src/domain/entities/order_notification.dart';

/// Estado del cubit global de notificaciones de órdenes.
///
/// `notifications` es la lista acumulada en memoria (descartada al cerrar la
/// app). `lastReceived` es un marker transient que solo se setea cuando llega
/// una notificación nueva — el listener de la SnackBar lo usa para disparar
/// el toast sin re-disparar al marcar como leídas.
class OrderNotificationState {
  const OrderNotificationState({
    this.notifications = const [],
    this.lastReceived,
  });

  final List<OrderNotification> notifications;
  final OrderNotification? lastReceived;

  int get unreadCount => notifications.where((n) => !n.read).length;
}
