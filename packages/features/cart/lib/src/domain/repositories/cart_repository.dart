import 'package:cart/src/domain/entities/cart.dart';
import 'package:catalog/catalog.dart';

abstract class CartRepository {
  Cart get current;

  void add(Product product, {int quantity = 1});

  void remove(String productId);

  void updateQuantity(String productId, int quantity);

  /// Reemplaza la foto del producto de una línea por la versión fresca del
  /// catálogo (stock/precio actuales) y limpia el flag de no disponible.
  /// La cantidad pedida NO se ajusta sola: si quedó por encima del stock
  /// nuevo, la línea pasa a bloquear el checkout y la UI lo muestra.
  void applyProductUpdate(String productId, Product product);

  /// Marca una línea como no disponible (el catálogo devolvió 404).
  void markUnavailable(String productId);

  void clear();
}
