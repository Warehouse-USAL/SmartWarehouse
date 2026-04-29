import 'package:design_system/design_system.dart';
import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTextSeparator extends StatelessWidget {
  const CustomTextSeparator({required this.text, super.key, this.styleBuilder});

  final String text;
  final CustomTextStyle Function(CustomTextStyles)? styleBuilder;

  @override
  Widget build(BuildContext context) {
    final color = CustomThemeExtension.of(context).black50;
    final divider = Expanded(child: Divider(thickness: 2, color: color));
    const customSpacer = CustomSpacer(width: CustomSpace.x3);
    return Row(
      children: [
        divider,
        customSpacer,
        CustomText(
          text,
          styleBuilder: styleBuilder ?? (styles) => styles.f16W500,
        ),
        customSpacer,
        divider,
      ],
    );
  }
}
