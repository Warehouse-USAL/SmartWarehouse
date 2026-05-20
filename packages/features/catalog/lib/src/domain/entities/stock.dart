/// Stock estructurado del contrato.
///
/// El endpoint de lista trae `available`, `min`, `reserved`.
/// El endpoint de detalle trae `available`, `low_stock_threshold`.
class Stock {
  const Stock({
    required this.available,
    this.min,
    this.reserved,
    this.lowStockThreshold,
  });

  final int available;
  final int? min;
  final int? reserved;
  final int? lowStockThreshold;

  bool get isOutOfStock => available <= 0;

  bool get isLow {
    final threshold = lowStockThreshold ?? min;
    if (threshold == null) return false;
    return available > 0 && available <= threshold;
  }

  static const empty = Stock(available: 0);
}
