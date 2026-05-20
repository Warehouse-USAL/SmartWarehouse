import 'package:catalog/catalog.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

enum StockStatus { inStock, low, out }

class StockBadge extends StatelessWidget {
  const StockBadge({required this.stock, super.key});
  final Stock stock;

  StockStatus get _status {
    if (stock.isOutOfStock) return StockStatus.out;
    if (stock.isLow) return StockStatus.low;
    return StockStatus.inStock;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final color = switch (status) {
      StockStatus.inStock => SwColors.stockIn,
      StockStatus.low => SwColors.yellowDark,
      StockStatus.out => SwColors.stockOut,
    };
    final dot = switch (status) {
      StockStatus.inStock => SwColors.stockInDot,
      StockStatus.low => SwColors.yellowDark,
      StockStatus.out => SwColors.stockOut,
    };
    final label = switch (status) {
      StockStatus.inStock => 'En stock · ${stock.available}',
      StockStatus.low => 'Bajo · ${stock.available}',
      StockStatus.out => 'Sin stock',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: SwText.body(size: 12, weight: FontWeight.w600, color: color)),
      ],
    );
  }
}
