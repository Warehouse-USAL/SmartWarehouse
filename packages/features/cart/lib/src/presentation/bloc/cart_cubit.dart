import 'package:cart/src/domain/entities/cart.dart';
import 'package:cart/src/domain/repositories/cart_repository.dart';
import 'package:catalog/catalog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<Cart> {
  CartCubit(this._repository, {CatalogRepository? catalogRepository})
    : _catalogRepository = catalogRepository,
      super(_repository.current);

  final CartRepository _repository;
  final CatalogRepository? _catalogRepository;

  /// Revalida cada línea contra el catálogo: refresca stock/precio y marca
  /// como no disponibles los productos que ya no existen (404). El stock
  /// puede cambiar en el backend mientras el carrito espera — sin esto, el
  /// usuario se entera recién cuando POST /orders rechaza la orden.
  ///
  /// Un error de red en un producto NO lo marca: no se castiga una línea por
  /// no poder verificarla.
  Future<void> revalidate() async {
    final catalog = _catalogRepository;
    if (catalog == null || _repository.current.isEmpty) return;
    final items = List.of(_repository.current.items);
    await Future.wait(
      items.map((item) async {
        final result = await catalog.getProductById(item.product.id);
        result.fold((failure) {
          if (failure.notFound) _repository.markUnavailable(item.product.id);
        }, (fresh) => _repository.applyProductUpdate(item.product.id, fresh));
      }),
    );
    if (isClosed) return;
    emit(_repository.current);
  }

  void add(Product product, {int quantity = 1}) {
    _repository.add(product, quantity: quantity);
    emit(_repository.current);
  }

  void remove(String productId) {
    _repository.remove(productId);
    emit(_repository.current);
  }

  void updateQuantity(String productId, int quantity) {
    _repository.updateQuantity(productId, quantity);
    emit(_repository.current);
  }

  void clear() {
    _repository.clear();
    emit(_repository.current);
  }
}
