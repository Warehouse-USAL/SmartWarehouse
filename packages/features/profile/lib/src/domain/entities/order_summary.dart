enum OrderStatus { shipped, delivered, processing, cancelled }

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.dateLabel,
    required this.itemCount,
    required this.status,
    required this.totalAmount,
  });

  final String id;
  final String dateLabel;
  final int itemCount;
  final OrderStatus status;
  final double totalAmount;

  String get formattedTotal {
    final cents = (totalAmount * 100).round();
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    return '\$$dollars.${remainder.toString().padLeft(2, '0')}';
  }

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
