import 'package:commons/commons.dart';
import 'package:profile/src/domain/entities/user_location.dart';

/// Persistencia local de la ubicación del usuario en este device.
///
/// El back NO tiene `bay`/`address` por usuario — el `User` solo guarda
/// `{id, email, name, role, active, createdAt}`. Por eso la persistimos
/// nosotros via Hive y la usamos al crear órdenes y al mostrar el perfil.
abstract class UserLocationStore {
  Future<UserLocation?> get();

  Future<void> save(UserLocation location);

  Future<void> clear();
}

class HiveUserLocationStore implements UserLocationStore {
  HiveUserLocationStore(this._persistence);

  final PersistenceHelper _persistence;

  static const _key = 'user-location';

  @override
  Future<UserLocation?> get() async {
    if (!await _persistence.exists(_key)) return null;
    final result =
        await _persistence.get(_key, _PersistableUserLocation.fromJson);
    return result.fold((_) => null, (p) => p.toEntity());
  }

  @override
  Future<void> save(UserLocation location) async {
    await _persistence.set(_key, _PersistableUserLocation.fromEntity(location));
  }

  @override
  Future<void> clear() async {
    await _persistence.remove(_key);
  }
}

/// Wrapper persistible — Hive necesita `toJson` y `fromJson`.
class _PersistableUserLocation implements PersistableObject {
  const _PersistableUserLocation({
    required this.destinationArea,
    required this.street,
    required this.postalCode,
    this.department,
    this.floor,
  });

  final String destinationArea;
  final String street;
  final String postalCode;
  final String? department;
  final String? floor;

  factory _PersistableUserLocation.fromEntity(UserLocation l) =>
      _PersistableUserLocation(
        destinationArea: l.destinationArea,
        street: l.street,
        postalCode: l.postalCode,
        department: l.department,
        floor: l.floor,
      );

  factory _PersistableUserLocation.fromJson(Map<String, dynamic> json) =>
      _PersistableUserLocation(
        destinationArea: (json['destinationArea'] as String?) ?? '',
        street: (json['street'] as String?) ?? '',
        postalCode: (json['postalCode'] as String?) ?? '',
        department: json['department'] as String?,
        floor: json['floor'] as String?,
      );

  UserLocation toEntity() => UserLocation(
        destinationArea: destinationArea,
        street: street,
        postalCode: postalCode,
        department: department,
        floor: floor,
      );

  @override
  Map<String, dynamic> toJson() => {
        'destinationArea': destinationArea,
        'street': street,
        'postalCode': postalCode,
        if (department != null) 'department': department,
        if (floor != null) 'floor': floor,
      };
}
