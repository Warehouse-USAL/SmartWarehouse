import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(10),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SwLoadingSkeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 10,
            ),
          ),
          SizedBox(height: 8),
          SwLoadingSkeleton(width: 48, height: 8),
          SizedBox(height: 6),
          SwLoadingSkeleton(width: 120, height: 12),
          SizedBox(height: 6),
          SwLoadingSkeleton(width: 90, height: 12),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SwLoadingSkeleton(width: 60, height: 14),
              SwLoadingSkeleton(width: 36, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
