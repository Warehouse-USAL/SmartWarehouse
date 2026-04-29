// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// SmartWarehouse industrial color palette.
///
/// Colors are designed for warehouse/logistics applications with
/// industrial design principles: clarity, efficiency, and professionalism.
class SmartWarehouseColors {
  // Industrial primary colors
  static const Color darkNavy = Color(0xff1A2332),
      electricBlue = Color(0xff0066FF),
      industryGreen = Color(0xff10B981),
      warningOrange = Color(0xffF59E0B),
      dangerRed = Color(0xffEF4444);

  // Neutral grays for hierarchy
  static const Color gray = Color(0xff6B7280),
      darkGray = Color(0xff374151),
      lightGray = Color(0xffF3F4F6),
      gray500 = Color(0xff6B7280),
      gray200 = Color(0xffE5E7EB),
      gray300 = Color(0xffD1D5DB);

  // Core colors
  static const Color primaryWhite = Color(0xffFFFFFF),
      primaryBlack = Color(0xff000000);

  // White variants
  static const Color white800 = Color(0xffF9FAFB),
      white10 = Color(0xffFCFCFD),
      white80 = Color.fromRGBO(255, 255, 255, 0.8),
      white90 = Color.fromRGBO(255, 255, 255, 0.9),
      white300 = Color.fromRGBO(255, 255, 255, 0.6);

  // Black variants
  static const Color black50 = Color.fromRGBO(0, 0, 0, 0.5),
      black70 = Color.fromRGBO(0, 0, 0, 0.7),
      black10 = Color.fromRGBO(0, 0, 0, 0.1),
      black20 = Color.fromRGBO(0, 0, 0, 0.2);

  // Status colors
  static const Color negative300 = Color(0xffFEE2E2),
      tertiary200 = Color.fromRGBO(233, 233, 233, 0.3);
}
