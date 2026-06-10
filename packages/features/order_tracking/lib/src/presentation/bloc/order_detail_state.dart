import 'package:order_tracking/src/domain/entities/order_item_detail.dart';
import 'package:orders/orders.dart';

sealed class OrderDetailState {
  const OrderDetailState();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.message);
  final String message;
}

class OrderDetailReady extends OrderDetailState {
  const OrderDetailReady({required this.order, required this.items});

  final Order order;
  final List<OrderItemDetail> items;
}
