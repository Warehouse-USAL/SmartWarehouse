import 'package:catalog/catalog.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.unavailable = false,
    this.fromRecommendation = false,
  });

  final Product product;
  final int quantity;

  /// True cuando la revalidación contra el catálogo devolvió 404: el
  /// producto fue eliminado o desactivado después de agregarlo al carrito.
  final bool unavailable;

  /// True si la línea nació del carrusel "suelen llevarse juntos". Viaja al
  /// backend en `POST /orders` para medir cuánto convierten las
  /// recomendaciones. Es pegajoso: una vez true, agregar más cantidad del
  /// mismo producto por otro camino no lo borra (la recomendación ya
  /// influyó en que la línea exista).
  final bool fromRecommendation;

  Money get subtotal => product.price * quantity;

  /// True si esta línea impide confirmar la orden: producto inexistente,
  /// cantidad inválida o mayor al stock disponible actual.
  bool get blocksCheckout =>
      unavailable || quantity <= 0 || quantity > product.stock.available;

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? unavailable,
    bool? fromRecommendation,
  }) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
    unavailable: unavailable ?? this.unavailable,
    fromRecommendation: fromRecommendation ?? this.fromRecommendation,
  );
}
