import 'package:commons/commons.dart';

/// Persistencia local de las órdenes creadas por el usuario en este device.
///
/// Existe porque `GET /orders` del back devuelve la lista global con permisos
/// que el usuario de la app no necesariamente tiene. En lugar de depender de
/// ese endpoint, guardamos los IDs de cada orden creada vía `POST /orders` y
/// el order_tracking hace `GET /orders/{id}` por cada uno para refrescar
/// estado.
abstract class OrderHistoryStore {
  /// Devuelve los IDs guardados, más nuevos primero.
  Future<List<String>> getOrderIds();

  /// Agrega un ID al principio de la lista (idempotente: si ya existe, no
  /// duplica ni reordena).
  Future<void> addOrderId(String id);

  /// Borra la historia. Útil en logout.
  Future<void> clear();
}

class HiveOrderHistoryStore implements OrderHistoryStore {
  HiveOrderHistoryStore(this._persistence);

  final PersistenceHelper _persistence;

  static const _key = 'order-history';

  @override
  Future<List<String>> getOrderIds() async {
    if (!await _persistence.exists(_key)) return [];
    final result = await _persistence.get(_key, PersistableOrderHistory.fromJson);
    return result.fold((_) => <String>[], (data) => data.ids);
  }

  @override
  Future<void> addOrderId(String id) async {
    final current = await getOrderIds();
    if (current.contains(id)) return;
    await _persistence.set(_key, PersistableOrderHistory(ids: [id, ...current]));
  }

  @override
  Future<void> clear() async {
    await _persistence.remove(_key);
  }
}

/// Wrapper persistible — Hive necesita un `toJson` y un `fromJson`.
class PersistableOrderHistory implements PersistableObject {
  const PersistableOrderHistory({required this.ids});

  final List<String> ids;

  factory PersistableOrderHistory.fromJson(Map<String, dynamic> json) {
    final raw = json['ids'];
    final ids = raw is List ? raw.cast<String>() : <String>[];
    return PersistableOrderHistory(ids: ids);
  }

  @override
  Map<String, dynamic> toJson() => {'ids': ids};
}
