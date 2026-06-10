import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// A centered loading spinner that uses the brand's primary color.
///
/// Use this widget to indicate a loading state for a whole page or a large
/// section of the UI.
class SwLoadingSpinner extends StatelessWidget {
  const SwLoadingSpinner({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color = SwColors.yellow,
  });

  /// The size of the spinner.
  final double size;

  /// The width of the line that forms the spinner.
  final double strokeWidth;

  /// The color of the spinner.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
