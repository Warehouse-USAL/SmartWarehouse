// ignore_for_file: non_constant_identifier_names

import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_theme.dart';
import 'package:flutter/material.dart';

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  CustomThemeExtension({
    required this.textStyles,
    required this.darkGray,
    required this.white10,
    required this.primaryWhite,
    required this.gray,
    required this.lightGray,
    required this.primaryBlack,
    required this.black50,
    required this.gray300,
    required this.white300,
    required this.black70,
    required this.black20,
    required this.white80,
    required this.black10,
    required this.white90,
    required this.negative300,
    required this.tertiary200,
    required this.gray500,
    required this.white800,
    required this.gray200,
  });

  final Color white10,
      darkGray,
      gray,
      primaryWhite,
      lightGray,
      primaryBlack,
      black50,
      gray300,
      white300,
      black70,
      white90,
      white80,
      black10,
      negative300,
      tertiary200,
      white800,
      gray500,
      black20,
      gray200;

  final CustomTextStyles textStyles;

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    Color? white10,
    Color? darkGray,
    Color? gray,
    Color? black20,
    CustomTextStyles? textStyles,
    Color? primaryWhite,
    Color? lightGray,
    Color? primaryBlack,
    Color? black50,
    Color? gray300,
    Color? white300,
    Color? black70,
    Color? white80,
    Color? white90,
    Color? black10,
    Color? negative300,
    Color? tertiary200,
    Color? gray500,
    Color? white800,
    Color? gray200,
  }) {
    return CustomThemeExtension(
      black20: black20 ?? this.black20,
      white10: white10 ?? this.white10,
      textStyles: textStyles ?? this.textStyles,
      darkGray: darkGray ?? this.darkGray,
      gray: gray ?? this.gray,
      primaryWhite: primaryWhite ?? this.primaryWhite,
      lightGray: lightGray ?? this.lightGray,
      primaryBlack: primaryBlack ?? this.primaryBlack,
      black50: black50 ?? this.black50,
      gray300: gray300 ?? this.gray300,
      white300: white300 ?? this.white300,
      black70: black70 ?? this.black70,
      white80: white80 ?? this.white80,
      black10: black10 ?? this.black10,
      negative300: negative300 ?? this.negative300,
      tertiary200: tertiary200 ?? this.tertiary200,
      gray500: gray500 ?? this.gray500,
      white800: white800 ?? this.white800,
      gray200: gray200 ?? this.gray200,
      white90: white90 ?? this.white90,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      black20: Color.lerp(black20, other.black20, t) ?? black20,
      white10: Color.lerp(white10, other.white10, t) ?? white10,
      textStyles: CustomTextStyles.lerp(textStyles, other.textStyles, t) ?? textStyles,
      darkGray: Color.lerp(darkGray, other.darkGray, t) ?? darkGray,
      gray: Color.lerp(gray, other.gray, t) ?? gray,
      primaryWhite: Color.lerp(primaryWhite, other.primaryWhite, t) ?? primaryWhite,
      lightGray: Color.lerp(lightGray, other.lightGray, t) ?? lightGray,
      primaryBlack: Color.lerp(primaryBlack, other.primaryBlack, t) ?? primaryBlack,
      black50: Color.lerp(black50, other.black50, t) ?? black50,
      gray300: Color.lerp(gray300, other.gray300, t) ?? gray300,
      white300: Color.lerp(white300, other.white300, t) ?? white300,
      black70: Color.lerp(black70, other.black70, t) ?? black70,
      white80: Color.lerp(white80, other.white80, t) ?? white80,
      black10: Color.lerp(black10, other.black10, t) ?? black10,
      negative300: Color.lerp(negative300, other.negative300, t) ?? negative300,
      tertiary200: Color.lerp(tertiary200, other.tertiary200, t) ?? tertiary200,
      gray500: Color.lerp(gray500, other.gray500, t) ?? gray500,
      white800: Color.lerp(white800, other.white800, t) ?? white800,
      gray200: Color.lerp(gray200, other.gray200, t) ?? gray200,
      white90: Color.lerp(white90, other.white90, t) ?? white90,
    );
  }

  static CustomThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<CustomThemeExtension>() ?? SmartWarehouseTheme().themeExtension;
}
