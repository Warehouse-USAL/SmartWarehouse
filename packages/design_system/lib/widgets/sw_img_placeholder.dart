import 'package:design_system/theme/sw_tokens.dart';
import 'package:flutter/material.dart';

/// Placeholder rayado en diagonal usado en el design system en lugar de fotos
/// reales. Acepta opcionalmente una `imageUrl` (carga la red con fallback a
/// rayas), un `label` que se muestra en la esquina inferior izquierda, y una
/// variante `tinted` con fondo amarillo soft.
class SwImgPlaceholder extends StatelessWidget {
  const SwImgPlaceholder({
    this.label,
    this.tinted = false,
    this.imageUrl,
    this.borderRadius = SwRadii.image,
    super.key,
  });

  final String? label;
  final bool tinted;
  final String? imageUrl;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Stripes(tinted: tinted),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _Stripes(tinted: tinted),
                  )
                : _Stripes(tinted: tinted),
          ),
          if (label != null)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xD9FFFFFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label!.toUpperCase(), style: SwText.mono(size: 10, letterSpacing: 0.08)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stripes extends StatelessWidget {
  const _Stripes({this.tinted = false});
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(tinted: tinted),
      size: Size.infinite,
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.tinted});
  final bool tinted;

  @override
  void paint(Canvas canvas, Size size) {
    final base = tinted ? SwColors.yellowSoft : SwColors.surface;
    final alt = tinted ? SwColors.yellowSoftAlt : SwColors.surfaceAlt;
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final stripe = Paint()..color = alt;
    const step = 20.0;
    final diag = size.width + size.height;
    for (double i = -diag; i < diag; i += step) {
      final path = Path()
        ..moveTo(i, 0)
        ..lineTo(i + 10, 0)
        ..lineTo(i + 10 + size.height, size.height)
        ..lineTo(i + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripe);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.tinted != tinted;
}
