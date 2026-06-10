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
  const OrderDetailReady({required this.order});
  final Order order;
}
