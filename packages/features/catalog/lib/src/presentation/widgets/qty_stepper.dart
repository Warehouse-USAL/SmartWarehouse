import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Quantity stepper from the design (lg variant = 44px buttons, used in
/// product detail; regular = 36px, used in cart line items).
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.large = false,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 44.0 : 36.0;
    return Container(
      decoration: BoxDecoration(
        color: SwColors.white,
        border: Border.all(color: SwColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            key: E2eKeys.productDetailQtyDecrement,
            size: size,
            icon: Icons.remove,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: size,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: SwText.body(size: large ? 16 : 15, weight: FontWeight.w600),
            ),
          ),
          _Btn(
            key: E2eKeys.productDetailQtyIncrement,
            size: size,
            icon: Icons.add,
            onTap: max == null || value < max! ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.size, required this.icon, required this.onTap, super.key});
  final double size;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: 18, color: onTap == null ? SwColors.text3 : SwColors.text),
      ),
    );
  }
}
