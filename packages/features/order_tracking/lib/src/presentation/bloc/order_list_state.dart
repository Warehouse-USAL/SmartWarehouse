import 'package:orders/orders.dart';

sealed class OrderListState {
  const OrderListState();
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListError extends OrderListState {
  const OrderListError(this.message);
  final String message;
}

class OrderListReady extends OrderListState {
  const OrderListReady({required this.orders});
  final List<Order> orders;
}
