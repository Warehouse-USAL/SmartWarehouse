import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for SmartWarehouse — derived from the brand HTML/CSS spec.
/// Use these directly instead of hard-coding hex/sizes/radii in feature code.
class SwColors {
  static const yellow = Color(0xFFFBC400);
  static const yellowHover = Color(0xFFFFCE1F);
  static const yellowDark = Color(0xFFB77900);
  static const yellowSoft = Color(0xFFFFF8D7);
  static const yellowSoftAlt = Color(0xFFFFEFA8);

  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F6F8);
  static const surfaceAlt = Color(0xFFECEEF1);
  static const surfaceBg = Color(0xFFECEEF2);
  static const border = Color(0xFFD1D5DB);

  static const text = Color(0xFF111827);
  static const text2 = Color(0xFF374151);
  static const text3 = Color(0xFF6B7280);

  static const link = Color(0xFF2563EB);
  static const infoBg = Color(0xFFDBEAFE);
  static const infoBorder = Color(0xFFBFDBFE);
  static const infoText = Color(0xFF1E3A8A);

  static const stockIn = Color(0xFF15803D);
  static const stockInDot = Color(0xFF16A34A);
  static const stockOut = Color(0xFFB91C1C);

  /// Rojo destructivo (cancelar orden, borrar). Mismo valor que [stockOut]
  /// a propósito — un solo rojo de marca — pero con nombre semántico para
  /// que el código de features no dependa de "stock" en flujos que no lo son.
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFAEDED);
  static const dangerBorder = Color(0xFFEFC9C9);

  /// Verde suave para fondos de estado positivo (chip "Completado").
  static const okSoft = Color(0xFFEAF5EE);
}

class SwRadii {
  static const card = 16.0;
  static const input = 12.0;
  static const pill = 999.0;
  static const image = 14.0;
  static const largeInput = 18.0;
}

class SwShadows {
  static const card = [
    BoxShadow(color: Color(0x0A111827), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x08111827), offset: Offset(0, 1), blurRadius: 1),
  ];

  static const elev = [
    BoxShadow(color: Color(0x14111827), offset: Offset(0, 6), blurRadius: 24),
    BoxShadow(color: Color(0x0A111827), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const yellowRing = [
    BoxShadow(color: Color(0x40FBC400), blurRadius: 0, spreadRadius: 3),
  ];
}

/// Typography helpers built on Google Fonts (Poppins display, Inter body,
/// JetBrains Mono for SKUs/labels). Each helper accepts overrides.
class SwText {
  static TextStyle display({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color color = SwColors.text,
    double letterSpacing = -0.02,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing * size,
      height: height,
    );
  }

  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = SwColors.text,
    double letterSpacing = -0.005,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing * size,
      height: height,
    );
  }

  static TextStyle label({
    double size = 13,
    Color color = SwColors.text2,
    FontWeight weight = FontWeight.w600,
  }) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle mono({
    double size = 10,
    Color color = SwColors.text3,
    double letterSpacing = 0.05,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing * size,
    );
  }
}
