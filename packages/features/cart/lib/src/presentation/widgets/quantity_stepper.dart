import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    final canDec = quantity > min;
    final canInc = max == null || quantity < max!;
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
            icon: Icons.remove,
            onTap: canDec ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: SwText.body(size: 15, weight: FontWeight.w600),
            ),
          ),
          _Btn(
            icon: Icons.add,
            onTap: canInc ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? SwColors.text3 : SwColors.text,
        ),
      ),
    );
  }
}
