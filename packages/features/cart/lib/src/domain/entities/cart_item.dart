import 'package:catalog/catalog.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    this.unavailable = false,
  });

  final Product product;
  final int quantity;

  /// True cuando la revalidación contra el catálogo devolvió 404: el
  /// producto fue eliminado o desactivado después de agregarlo al carrito.
  final bool unavailable;

  Money get subtotal => product.price * quantity;

  /// True si esta línea impide confirmar la orden: producto inexistente,
  /// cantidad inválida o mayor al stock disponible actual.
  bool get blocksCheckout =>
      unavailable || quantity <= 0 || quantity > product.stock.available;

  CartItem copyWith({Product? product, int? quantity, bool? unavailable}) =>
      CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
        unavailable: unavailable ?? this.unavailable,
      );
}
