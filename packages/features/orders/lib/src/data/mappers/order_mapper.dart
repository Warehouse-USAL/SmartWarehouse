import 'package:catalog/catalog.dart';
import 'package:orders/src/data/dtos/order_dto.dart';
import 'package:orders/src/data/dtos/order_item_dto.dart';
import 'package:orders/src/domain/entities/order.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

extension OrderDtoMapper on OrderDto {
  /// El backend NO devuelve precios en el endpoint de orders; se reciben los
  /// `fallbackItems` desde la UI (los items que enviamos al crear la orden)
  /// para preservar nombre y precio en post-creación.
  Order toEntity({required List<OrderItem> fallbackItems}) {
    final currency = fallbackItems.isEmpty
        ? 'ARS'
        : fallbackItems.first.unitPrice.currency;
    var total = Money.zero(currency);
    for (final i in fallbackItems) {
      total = total + i.subtotal;
    }
    return Order(
      id: id,
      items: fallbackItems,
      status: _parseStatus(status),
      createdAt: _parseDate(timestamps?.createdAt) ?? DateTime.now(),
      total: total,
    );
  }
}

extension OrderItemDtoMapper on OrderItemDto {
  /// Sin price: el back no devuelve precio en items. Usar con `fallbackItems`
  /// que sí tienen unitPrice.
  OrderItem toEntity({required Money unitPrice, String? fallbackName}) =>
      OrderItem(
        productId: productId,
        productName: name ?? fallbackName ?? '',
        quantity: quantity,
        unitPrice: unitPrice,
      );
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

OrderStatus _parseStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'in_progress':
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'shipped':
      return OrderStatus.shipped;
    case 'completed':
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}
