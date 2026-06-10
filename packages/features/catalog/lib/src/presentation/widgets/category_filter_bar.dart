import 'package:catalog/src/domain/entities/product_category.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final List<ProductCategory> categories;
  final ProductCategory? selectedCategory;
  final ValueChanged<ProductCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: 'Todos',
              isActive: selectedCategory == null,
              onTap: () => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return _Chip(
            label: category.label,
            isActive: selectedCategory == category,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? SwColors.text : SwColors.surface,
      borderRadius: BorderRadius.circular(SwRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SwRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: SwText.body(
              size: 13,
              weight: FontWeight.w500,
              color: isActive ? SwColors.white : SwColors.text2,
            ),
          ),
        ),
      ),
    );
  }
}
