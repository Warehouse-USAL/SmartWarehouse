import 'package:cart/src/domain/entities/cart.dart';
import 'package:orders/orders.dart';

/// Mapper Cart -> items de orden para `POST /orders`.
extension CartOrderMapper on Cart {
  List<OrderItem> toOrderItems() => items
      .map(
        (i) => OrderItem(
          productId: i.product.id,
          productName: i.product.name,
          unitPrice: i.product.price,
          quantity: i.quantity,
        ),
      )
      .toList();
}
