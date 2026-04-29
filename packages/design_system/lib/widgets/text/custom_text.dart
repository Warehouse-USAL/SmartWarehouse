// ignore_for_file: prefer_asserts_in_initializer_lists, prefer_asserts_with_message

import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  CustomText(
    this.text, {
    super.key,
    this.styleBuilder,
    this.useLineHeight = true,
    this.textAlign,
    this.maxLines,
    this.textOverflow,
    this.color,
    this.style,
  }) {
    assert(style != null || styleBuilder != null);
  }

  final String text;
  final TextStyle? style;
  final CustomTextStyle Function(CustomTextStyles)? styleBuilder;
  final bool useLineHeight;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? styleBuilder?.call(CustomTextStyles.of(context)).value;
    return Text(
      text,
      style: textStyle?.copyWith(height: useLineHeight ? null : 1, color: color),
      overflow: textOverflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
    );
  }
}
