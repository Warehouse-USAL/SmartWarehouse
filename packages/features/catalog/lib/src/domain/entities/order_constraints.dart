/// Restricciones de orden del contrato.
///
/// JSON key del backend: `order_constrains` (sic — typo del contrato).
class OrderConstraints {
  const OrderConstraints({required this.maxQuantityPerOrder});

  final int maxQuantityPerOrder;

  static const defaults = OrderConstraints(maxQuantityPerOrder: 99);
}
