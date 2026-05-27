/// Destino de la orden. El backend de SmartWarehouse acepta un único campo
/// `destination_area` (string plano) en `POST /orders`.
class OrderDestination {
  const OrderDestination({required this.area});

  /// Mandado al backend como `destination_area`.
  final String area;

  static const defaults = OrderDestination(area: 'Bay 14');
}
