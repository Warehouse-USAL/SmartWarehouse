/// Ubicación física del producto en el depósito.
class ProductLocation {
  const ProductLocation({
    required this.idZone,
    required this.idLine,
    required this.idPosition,
    required this.height,
  });

  final String idZone;
  final String idLine;
  final String idPosition;
  final String height;
}
