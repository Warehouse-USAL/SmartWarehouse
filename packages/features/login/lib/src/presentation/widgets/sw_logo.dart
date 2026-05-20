import 'package:flutter/material.dart';

/// SmartWarehouse brand mark + wordmark.
///
/// Renders the yellow hexagonal logo (with the bold black box icon)
/// followed by the `SmartWarehouse` wordmark, using the official
/// transparent-background PNG shipped under `assets/images/`.
class SwLogo extends StatelessWidget {
  const SwLogo({
    this.size = 36,
    this.markOnly = false,
    super.key,
  });

  /// Height of the rendered mark in logical pixels.
  /// 36 = default app-bar size, 56 = large hero size.
  final double size;

  /// When true, renders only the hexagonal mark without the wordmark.
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    final asset = markOnly
        ? 'assets/images/sw_logo_mark.png'
        : 'assets/images/sw_logo_full.png';

    return Semantics(
      label: 'SmartWarehouse',
      image: true,
      child: Image.asset(
        asset,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
