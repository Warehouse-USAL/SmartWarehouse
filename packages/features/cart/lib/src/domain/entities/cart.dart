import 'package:cart/src/domain/entities/cart_item.dart';
import 'package:catalog/catalog.dart';

class Cart {
  const Cart({required this.items});

  factory Cart.empty() => const Cart(items: []);

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// True si hay items con monedas distintas — un carrito así no tiene un
  /// total representable y no debe poder confirmarse.
  bool get hasMixedCurrencies {
    if (items.isEmpty) return false;
    final currency = items.first.product.price.currency;
    return items.any((i) => i.product.price.currency != currency);
  }

  /// Sum de subtotales. Devuelve `null` si el carrito está vacío (sin moneda
  /// de referencia) o si hay monedas mezcladas (sumar lanzaría; la UI debe
  /// chequear [hasMixedCurrencies] y bloquear el checkout).
  Money? get total {
    if (items.isEmpty || hasMixedCurrencies) return null;
    final currency = items.first.product.price.currency;
    var sum = Money.zero(currency);
    for (final i in items) {
      sum = sum + i.subtotal;
    }
    return sum;
  }

  /// True si hay items con cantidad inválida: cero/negativa o mayor al stock
  /// disponible. Un carrito así no puede confirmarse (sería sobreventa).
  bool get hasInvalidQuantities => items.any(
        (i) => i.quantity <= 0 || i.quantity > i.product.stock.available,
      );

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int quantityOf(String productId) {
    final match = items.where((i) => i.product.id == productId);
    if (match.isEmpty) return 0;
    return match.first.quantity;
  }
}
