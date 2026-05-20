import 'package:flutter/material.dart';

/// SmartWarehouse brand mark + wordmark.
///
/// Renderiza el logo hexagonal amarillo seguido del wordmark "SmartWarehouse",
/// usando el PNG con fondo transparente ubicado en `assets/images/`.
class SwLogo extends StatelessWidget {
  const SwLogo({
    this.size = 36,
    this.markOnly = false,
    super.key,
  });

  /// Altura del logo en píxeles lógicos.
  /// 36 = tamaño de app bar, 56 = tamaño hero.
  final double size;

  /// Si true, renderiza solo el mark (sin wordmark).
  final bool markOnly;

  @override
  Widget build(BuildContext context) {
    final asset = markOnly
        ? 'assets/images/sw_logo_mark.png'
        : 'assets/images/sw_logo_full.png';
    return Semantics(
      label: 'SmartWarehouse',
      image: true,
      child: Image.asset(
        asset,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Versión compacta — solo el mark cuadrado, manteniendo proporción.
class SwLogoMark extends StatelessWidget {
  const SwLogoMark({this.size = 36, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const SwLogo(markOnly: true),
    );
  }
}
