import 'package:catalog/catalog.dart';
import 'package:orders/orders.dart';

/// Item de una orden con los datos del producto hidratados desde el catálogo.
///
/// El back devuelve los items con `{productId, sku, quantity}` solamente. Para
/// mostrar nombre, imagen y precio en la UI hacemos `GET /products/{id}` por
/// cada uno. Si el fetch falla (404, producto borrado, etc.) `product` queda
/// en null y la UI usa los campos disponibles del `OrderItem` como fallback.
class OrderItemDetail {
  const OrderItemDetail({required this.item, this.product});

  final OrderItem item;
  final Product? product;

  String get name {
    final p = product;
    if (p != null) return p.name;
    if (item.productName.isNotEmpty) return item.productName;
    return item.productId;
  }

  String? get imageUrl => product?.imageUrl;

  Money get unitPrice => product?.price ?? item.unitPrice;

  Money get subtotal => unitPrice * item.quantity;
}
