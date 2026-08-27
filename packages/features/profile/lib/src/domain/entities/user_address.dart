/// Dirección de entrega del usuario.
///
/// Espejo del bloque `address` del `User` del back. Persistida en la cuenta
/// (vía `PATCH /users/me`) — no en Hive del device. Se autocompleta en el
/// form de creación de orden.
class UserAddress {
  const UserAddress({
    required this.street,
    required this.postalCode,
    this.department,
    this.floor,
  });

  final String street;
  final String postalCode;
  final String? department;
  final String? floor;

  bool get isComplete =>
      street.trim().isNotEmpty && postalCode.trim().isNotEmpty;

  /// Una línea para mostrar en el header del perfil.
  String get summary {
    final parts = <String>[street];
    if (department != null && department!.trim().isNotEmpty) {
      parts.add('Dpto ${department!}');
    }
    if (floor != null && floor!.trim().isNotEmpty) parts.add('Piso ${floor!}');
    parts.add('CP $postalCode');
    return parts.join(' · ');
  }

  UserAddress copyWith({
    String? street,
    String? postalCode,
    String? department,
    String? floor,
  }) =>
      UserAddress(
        street: street ?? this.street,
        postalCode: postalCode ?? this.postalCode,
        department: department ?? this.department,
        floor: floor ?? this.floor,
      );
}
