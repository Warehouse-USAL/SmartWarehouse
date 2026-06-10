import 'package:order_tracking/src/domain/entities/order_status_change.dart';

sealed class OrderNotificationState {
  const OrderNotificationState();
}

class OrderNotificationIdle extends OrderNotificationState {
  const OrderNotificationIdle();
}

class OrderNotificationReceived extends OrderNotificationState {
  const OrderNotificationReceived(this.change);
  final OrderStatusChange change;
}
