import 'package:catalog/catalog.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';
import 'package:orders/orders.dart';

extension OrderTrackingItemDtoMapper on OrderTrackingItemDto {
  Order toEntity() {
    final mappedItems = items.map((i) => i.toEntity()).toList();
    return Order(
      id: id,
      status: _parseStatus(status),
      items: mappedItems,
      createdAt: createdAt != null
          ? (DateTime.tryParse(createdAt!) ?? DateTime.now())
          : DateTime.now(),
      total: Money.zero('ARS'),
    );
  }
}

extension OrderTrackingLineItemDtoMapper on OrderTrackingLineItemDto {
  OrderItem toEntity() => OrderItem(
        productId: productId,
        productName: name ?? '',
        quantity: quantity,
        unitPrice: Money.zero('ARS'),
      );
}

OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'in_progress':
    case 'confirmed':
    case 'shipped':
      return OrderStatus.inProgress;
    case 'completed':
    case 'delivered':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
