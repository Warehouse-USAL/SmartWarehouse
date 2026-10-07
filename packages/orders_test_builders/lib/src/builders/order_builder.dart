import 'package:catalog/catalog.dart';
import 'package:catalog_test_builders/catalog_test_builders.dart';
import 'package:orders/orders.dart';

import 'order_item_builder.dart';

/// Fecha fija: un `DateTime.now()` acá haría que cualquier aserción sobre
/// `createdAt` dependa del reloj. No es `const` porque los constructores de
/// [DateTime] no lo son.
final _createdAt = DateTime.utc(2026, 1, 1);

/// Construye una [Order] con defaults razonables.
///
/// Si no se pasa `total`, se deriva sumando los `subtotal` de `items`. Es una
/// pizca de lógica adentro de un builder, y se acepta a propósito: la
/// alternativa —un [Money] fijo— se desincroniza apenas el test pasa otros
/// items, y deja objetos que no podrían existir en producción. Un `total`
/// explícito sigue ganando, justamente para poder armar esa incoherencia
/// cuando el test la necesita.
Order anOrder({
  String id = 'o-1',
  List<OrderItem>? items,
  OrderStatus status = OrderStatus.pending,
  DateTime? createdAt,
  Money? total,
}) {
  final resolvedItems = items ?? [anOrderItem()];

  return Order(
    id: id,
    items: resolvedItems,
    status: status,
    createdAt: createdAt ?? _createdAt,
    total: total ?? _sumOf(resolvedItems),
  );
}

/// Suma los subtotales. La moneda sale del primer item porque [Money.+] tira
/// si se mezclan monedas: arrancar el fold en una moneda fija haría fallar
/// cualquier orden que no sea en esa. Sin items no hay de dónde sacarla, y se
/// cae al default compartido de [aMoney].
Money _sumOf(List<OrderItem> items) => items.fold(
      Money.zero(items.isEmpty ? aMoney().currency : items.first.unitPrice.currency),
      (total, item) => total + item.subtotal,
    );
