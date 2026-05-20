import 'package:catalog/catalog.dart';

/// Destino de la orden alineado al contrato `POST /orders`.
///
/// `area` y `addressLine` se pueden derivar de `product.location` (zona +
/// línea/posición/altura) cuando no hay una dirección explícita configurada
/// por el usuario.
class OrderDestination {
  const OrderDestination({
    required this.area,
    required this.addressLine,
  });

  final String area;
  final String addressLine;

  /// Construye destino consolidando la `location` de los productos del carrito.
  ///
  /// - Si todos comparten `idZone` → `area = idZone`.
  /// - Si hay zonas distintas → `area = "Mixto"`.
  /// - Si ningún item tiene location → devuelve `null` (caller decide fallback).
  ///
  /// `addressLine` resume línea/posición/altura del primer item con location.
  static OrderDestination? fromProductLocations(Iterable<Product> products) {
    final locations = products
        .map((p) => p.location)
        .whereType<ProductLocation>()
        .toList(growable: false);
    if (locations.isEmpty) return null;

    final zones = locations.map((l) => l.idZone).toSet();
    final area = zones.length == 1 ? zones.first : 'Mixto';

    final first = locations.first;
    final addressLine =
        'Línea ${first.idLine} · Posición ${first.idPosition} · Altura ${first.height}';

    return OrderDestination(area: area, addressLine: addressLine);
  }
}
