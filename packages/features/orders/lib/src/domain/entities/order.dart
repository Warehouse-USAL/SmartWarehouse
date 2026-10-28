import 'package:catalog/catalog.dart';
import 'package:orders/src/domain/entities/order_item.dart';
import 'package:orders/src/domain/entities/order_status.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    this.cancelReason,
  });

  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final Money total;

  /// Motivo de cancelación informado por el backend (`cancel_reason`). Es
  /// opcional: las órdenes sin motivo (o de un backend viejo) lo dejan en null.
  /// Puede ser texto interno (ej. `INSUFFICIENT_STOCK: <sku>...`): para
  /// mostrarlo al usuario usar [cancelReasonMessage].
  final String? cancelReason;

  /// Explicación amigable del motivo de cancelación, o null si no hay motivo.
  /// No filtra SKUs ni texto interno del backend.
  String? get cancelReasonMessage {
    final reason = cancelReason?.trim();
    if (reason == null || reason.isEmpty) return null;
    if (reason.toUpperCase().startsWith('INSUFFICIENT_STOCK')) {
      return 'La orden se canceló porque el stock de algunos productos '
          'cambió y ya no alcanza para completarla.';
    }
    return null;
  }

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
    Money? total,
    String? cancelReason,
  }) => Order(
    id: id ?? this.id,
    items: items ?? this.items,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    total: total ?? this.total,
    cancelReason: cancelReason ?? this.cancelReason,
  );
}
