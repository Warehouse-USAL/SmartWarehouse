import 'package:catalog/catalog.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';
import 'package:orders/orders.dart';

extension OrderTrackingItemDtoMapper on OrderTrackingItemDto {
  Order toEntity() {
    final mappedItems = items.map((i) => i.toEntity()).toList();
    // Preferimos timestamps.createdAt (el back nuevo lo pone ahí). Si no
    // está, caemos al createdAt de root (legacy) y por último a now.
    final rawCreatedAt = timestamps?.createdAt ?? createdAt;
    return Order(
      id: id,
      status: parseOrderStatus(status),
      items: mappedItems,
      // Fecha ausente/ilegible → epoch para que la orden quede al final del
      // listado (ordenado por fecha) en vez de arriba como si fuera nueva.
      createdAt: rawCreatedAt != null
          ? (DateTime.tryParse(rawCreatedAt) ??
              DateTime.fromMillisecondsSinceEpoch(0))
          : DateTime.fromMillisecondsSinceEpoch(0),
      total: Money.zero('ARS'),
    );
  }
}

extension OrderTrackingLineItemDtoMapper on OrderTrackingLineItemDto {
  OrderItem toEntity() => OrderItem(
        productId: productId,
        // Sin nombre del back ni hidratación de catálogo, mejor un texto
        // explícito que el UUID crudo o un string vacío.
        productName: name ?? 'Producto no disponible',
        quantity: quantity,
        unitPrice: Money.zero('ARS'),
      );
}

OrderStatus parseOrderStatus(String raw) {
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
