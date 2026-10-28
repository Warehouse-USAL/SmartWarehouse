import 'package:cart/src/domain/entities/cart.dart';
import 'package:catalog/catalog.dart';

abstract class CartRepository {
  Cart get current;

  /// Agrega [quantity] unidades de [product]. `fromRecommendation` marca que
  /// el agregado vino del carrusel de recomendaciones; al mergear con una
  /// línea existente el flag es pegajoso (OR): si alguna vez fue true, queda
  /// true aunque después se agregue más cantidad por otro camino.
  void add(
    Product product, {
    int quantity = 1,
    bool fromRecommendation = false,
  });

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
