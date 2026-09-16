import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:orders/orders.dart';

/// Construye un [OrderItem] con defaults razonables.
///
/// `quantity` arranca en 2 y no en 1 por el mismo motivo por el que [aMoney]
/// no arranca en 0: con cantidad 1 el `subtotal` es igual al `unitPrice`, así
/// que un bug de multiplicación pasa desapercibido.
///
/// `unitPrice` no puede ser un default en la firma porque [aMoney] no es una
/// expresión constante; se resuelve adentro.
OrderItem anOrderItem({
  String productId = 'p-1',
  String productName = 'Producto 1',
  int quantity = 2,
  Money? unitPrice,
}) =>
    OrderItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice ?? aMoney(),
    );
