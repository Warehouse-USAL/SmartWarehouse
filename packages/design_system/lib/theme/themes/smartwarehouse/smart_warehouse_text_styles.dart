import 'package:design_system/theme/theme_data/custom_text_styles.dart';
import 'package:design_system/theme/themes/smartwarehouse/smart_warehouse_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartWarehouseTextStyles extends CustomTextStyles {
  SmartWarehouseTextStyles()
      : super(
          f20W700: F20W700TextStyle(),
          f14W600: F14W600TextStyle(),
          f16W600: F16W600TextStyle(),
          f16W500: F16W500TextStyle(),
          f18W500: F18W500TextStyle(),
          f24W500: F24W500TextStyle(),
          f14W500: F14W500TextStyle(),
          f12W700: F12W700TextStyle(),
          f16W700: F16W700TextStyle(),
          f12W500: F12W500TextStyle(),
          f14W600PJS: F14W600PJSTextStyle(),
          f10W500: F10W500TextStyle(),
          f18W700: F18W700TextStyle(),
          f10W700: F10W700TextStyle(),
          f8W700: F8W700TextStyle(),
          f14W700PJS: F14W700PJSTextStyle(),
          f24W700: F24W700TextStyle(),
          f20W500: F20W500TextStyle(),
          f13W400: F13W400TextStyle(),
        );
}

class F14W700PJSTextStyle extends CustomTextStyle {
  F14W700PJSTextStyle()
      : super(
          GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        );
}

class F24W700TextStyle extends CustomTextStyle {
  F24W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F8W700TextStyle extends CustomTextStyle {
  F8W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 7,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F20W500TextStyle extends CustomTextStyle {
  F20W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F10W700TextStyle extends CustomTextStyle {
  F10W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F18W700TextStyle extends CustomTextStyle {
  F18W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F12W500TextStyle extends CustomTextStyle {
  F12W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F10W500TextStyle extends CustomTextStyle {
  F10W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
            height: 1.6,
          ),
        );
}

class F14W600PJSTextStyle extends CustomTextStyle {
  F14W600PJSTextStyle()
      : super(
          GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        );
}

class F16W700TextStyle extends CustomTextStyle {
  F16W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F12W700TextStyle extends CustomTextStyle {
  F12W700TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F14W500TextStyle extends CustomTextStyle {
  F14W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
            height: 1.4,
          ),
        );
}

class F13W400TextStyle extends CustomTextStyle {
  F13W400TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: SmartWarehouseColors.primaryBlack,
            height: 1.58,
          ),
        );
}

class F14W600TextStyle extends CustomTextStyle {
  F14W600TextStyle()
      : super(
          GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
}

class F20W700TextStyle extends CustomTextStyle {
  F20W700TextStyle()
      : super(
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: SmartWarehouseColors.darkGray,
          ),
        );
}

class F24W500TextStyle extends CustomTextStyle {
  F24W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F16W500TextStyle extends CustomTextStyle {
  F16W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
            letterSpacing: -0.057,
            height: 1.35,
          ),
        );
}

class F18W500TextStyle extends CustomTextStyle {
  F18W500TextStyle()
      : super(
          const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: SmartWarehouseColors.primaryBlack,
          ),
        );
}

class F16W600TextStyle extends CustomTextStyle {
  F16W600TextStyle()
      : super(
          GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: SmartWarehouseColors.darkGray,
          ),
        );
}

enum FontWeights {
  light(FontWeight.w300),
  regular(FontWeight.w400),
  medium(FontWeight.w500),
  semiheavy(FontWeight.w800),
  heavy(FontWeight.w900),
  semiBold(FontWeight.w600);

  const FontWeights(this.value);

  final FontWeight value;
}
