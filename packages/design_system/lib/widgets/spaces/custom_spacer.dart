import 'package:flutter/material.dart';

class CustomSpacer extends StatelessWidget {
  const CustomSpacer({super.key, this.height, this.width});

  final CustomSpace? height, width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height?.value ?? 0, width: width?.value ?? 0);
  }
}

enum CustomSpace {
  x1(4),
  x2(8),
  x3(12),
  x4(16),
  x5(20),
  x6(24),
  x7(32);

  const CustomSpace(this.value);

  final double value;
}
