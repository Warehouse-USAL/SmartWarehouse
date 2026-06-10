import 'package:catalog/catalog.dart';
import 'package:catalog/src/presentation/widgets/stock_badge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.tinted = false,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: SwColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SwImgPlaceholder(
                  label: product.category.label,
                  tinted: tinted,
                  imageUrl: product.imageUrl,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.sku,
                style: SwText.mono(size: 10, letterSpacing: 0.05),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                style: SwText.body(size: 13, weight: FontWeight.w600, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        product.price.formatted,
                        style: SwText.display(size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: StockBadge(stock: product.stock),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
