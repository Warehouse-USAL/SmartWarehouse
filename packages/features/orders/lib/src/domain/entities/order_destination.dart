/// Destino completo de la orden. El back acepta en `POST /orders`:
/// - `destination_area` (string plano top-level)
/// - `address: { street, postal_code, department?, floor? }`
///
/// Antes solo modelábamos `area`, hoy también llevamos los campos del
/// `address` porque el back los hizo requeridos (street + postalCode).
class OrderDestination {
  const OrderDestination({
    required this.area,
    required this.street,
    required this.postalCode,
    this.department,
    this.floor,
  });

  /// `destination_area` top-level del request.
  final String area;

  /// Dentro del bloque `address`.
  final String street;
  final String postalCode;
  final String? department;
  final String? floor;

  static const defaults = OrderDestination(
    area: 'Bay 14',
    street: 'Av. Siempre Viva 742',
    postalCode: '1414',
  );
}
