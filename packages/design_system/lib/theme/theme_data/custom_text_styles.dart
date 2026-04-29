import 'package:design_system/theme/extensions/custom_theme_extension.dart';
import 'package:flutter/material.dart';

class CustomTextStyles {
  CustomTextStyles({
    required this.f20W700,
    required this.f14W600,
    required this.f16W500,
    required this.f16W600,
    required this.f18W500,
    required this.f24W500,
    required this.f14W500,
    required this.f12W700,
    required this.f16W700,
    required this.f12W500,
    required this.f14W600PJS,
    required this.f10W500,
    required this.f18W700,
    required this.f10W700,
    required this.f8W700,
    required this.f14W700PJS,
    required this.f24W700,
    required this.f20W500,
    required this.f13W400,
  });

  final CustomTextStyle f20W500,
      f20W700,
      f14W600,
      f16W500,
      f16W600,
      f18W500,
      f24W500,
      f14W500,
      f12W700,
      f16W700,
      f12W500,
      f14W600PJS,
      f10W500,
      f18W700,
      f8W700,
      f14W700PJS,
      f10W700,
      f24W700,
      f13W400;

  static CustomTextStyles? lerp(CustomTextStyles textStyle, CustomTextStyles other, double t) {
    return CustomTextStyles(
      f20W700: CustomTextStyle.lerp(textStyle.f20W700, other.f20W700, t) ?? textStyle.f20W700,
      f14W600: CustomTextStyle.lerp(textStyle.f14W600, other.f14W600, t) ?? textStyle.f14W600,
      f16W500: CustomTextStyle.lerp(textStyle.f16W500, other.f16W500, t) ?? textStyle.f16W500,
      f16W600: CustomTextStyle.lerp(textStyle.f16W600, other.f16W600, t) ?? textStyle.f16W600,
      f18W500: CustomTextStyle.lerp(textStyle.f18W500, other.f18W500, t) ?? textStyle.f18W500,
      f24W500: CustomTextStyle.lerp(textStyle.f24W500, other.f24W500, t) ?? textStyle.f24W500,
      f14W500: CustomTextStyle.lerp(textStyle.f14W500, other.f14W500, t) ?? textStyle.f14W500,
      f12W700: CustomTextStyle.lerp(textStyle.f12W700, other.f12W700, t) ?? textStyle.f12W700,
      f16W700: CustomTextStyle.lerp(textStyle.f16W700, other.f16W700, t) ?? textStyle.f16W700,
      f12W500: CustomTextStyle.lerp(textStyle.f12W500, other.f12W500, t) ?? textStyle.f12W500,
      f14W600PJS: CustomTextStyle.lerp(textStyle.f14W600PJS, other.f14W600PJS, t) ?? textStyle.f14W600PJS,
      f10W500: CustomTextStyle.lerp(textStyle.f10W500, other.f10W500, t) ?? textStyle.f10W500,
      f18W700: CustomTextStyle.lerp(textStyle.f18W700, other.f18W700, t) ?? textStyle.f18W700,
      f10W700: CustomTextStyle.lerp(textStyle.f10W700, other.f10W700, t) ?? textStyle.f10W700,
      f8W700: CustomTextStyle.lerp(textStyle.f8W700, other.f8W700, t) ?? textStyle.f8W700,
      f14W700PJS: CustomTextStyle.lerp(textStyle.f14W700PJS, other.f14W700PJS, t) ?? textStyle.f14W700PJS,
      f24W700: CustomTextStyle.lerp(textStyle.f24W700, other.f24W700, t) ?? textStyle.f24W700,
      f20W500: CustomTextStyle.lerp(textStyle.f20W500, other.f20W500, t) ?? textStyle.f20W500,
      f13W400: CustomTextStyle.lerp(textStyle.f13W400, other.f13W400, t) ?? textStyle.f13W400,
    );
  }

  static CustomTextStyles of(BuildContext context) => CustomThemeExtension.of(context).textStyles;
}

class CustomTextStyle {
  CustomTextStyle(this.value);

  final TextStyle value;

  static CustomTextStyle? lerp(CustomTextStyle textStyle, CustomTextStyle other, double t) {
    return CustomTextStyle(TextStyle.lerp(textStyle.value, other.value, t) ?? textStyle.value);
  }
}
