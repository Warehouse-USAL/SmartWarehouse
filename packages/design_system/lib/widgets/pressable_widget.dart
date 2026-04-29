import 'package:flutter/material.dart';

class PressableWidget extends StatelessWidget {
  const PressableWidget({
    required this.child,
    super.key,
    this.borderRadius,
    this.pressedColor,
    this.disabledColor,
    this.backgroundColor,
    this.onPressed,
    this.hasVibration = true,
  });

  final bool hasVibration;

  final BorderRadius? borderRadius;
  final Color? pressedColor, disabledColor, backgroundColor;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isDisabled ? disabledColor : backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        splashColor: pressedColor,
        highlightColor: pressedColor,
        onTap: _onPressedCallback(),
        child: child,
      ),
    );
  }

  VoidCallback? _onPressedCallback() {
    return onPressed == null ? null : _onTap;
  }

  void _onTap() => onPressed?.call();

  bool get _isDisabled => onPressed == null;
}
