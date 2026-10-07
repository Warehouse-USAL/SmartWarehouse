import 'package:catalog/catalog.dart';

enum OrderStatus { shipped, delivered, processing, cancelled }

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.dateLabel,
    required this.itemCount,
    required this.status,
    this.total,
    this.createdAt,
  });

  final String id;
  final String dateLabel;
  final int itemCount;
  final OrderStatus status;

  /// Total real de la orden. `null` cuando no se pudo calcular de forma
  /// confiable (precio de algún producto no disponible o monedas mezcladas):
  /// en ese caso la UI muestra "—" en vez de un monto incorrecto.
  final Money? total;

  final DateTime? createdAt;

  /// Único formato de dinero de la app: `Money.formatted`.
  String get formattedTotal => total?.formatted ?? '—';

  String get statusLabel {
    return switch (status) {
      OrderStatus.shipped => 'Enviado',
      OrderStatus.delivered => 'Entregado',
      OrderStatus.processing => 'En proceso',
      OrderStatus.cancelled => 'Cancelado',
    };
  }

  String get itemsLabel =>
      '$itemCount ${itemCount == 1 ? 'artículo' : 'artículos'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OrderSummary && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
