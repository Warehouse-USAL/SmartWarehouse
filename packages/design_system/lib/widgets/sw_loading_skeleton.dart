import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// A reusable shimmer-effect skeleton loader for lists and cards.
///
/// It provides a consistent animation across the app by interpolating
/// between border and surface colors.
class SwLoadingSkeleton extends StatefulWidget {
  const SwLoadingSkeleton({
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  /// Creates a circular skeleton.
  factory SwLoadingSkeleton.circle({required double size, Key? key}) {
    return SwLoadingSkeleton(
      width: size,
      height: size,
      borderRadius: size / 2,
      key: key,
    );
  }

  @override
  State<SwLoadingSkeleton> createState() => _SwLoadingSkeletonState();
}

class _SwLoadingSkeletonState extends State<SwLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          SwColors.border.withValues(alpha: 0.5),
          SwColors.surface,
          _controller.value,
        )!;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
