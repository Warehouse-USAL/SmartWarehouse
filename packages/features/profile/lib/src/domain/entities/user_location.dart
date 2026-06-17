/// Ubicación de entrega persistida localmente por el usuario.
///
/// Espeja los campos que el back pide al crear una orden:
/// - `destinationArea` (req): zona del depósito (ej "Bay 14"). El back lo
///   recibe en `destination_area` del top-level del CreateOrderRequest.
/// - `street, postalCode` (req): dentro del bloque `address`.
/// - `department, floor` (opt): dentro del bloque `address`.
class UserLocation {
  const UserLocation({
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

  /// Suficiente para mandar una orden: con los 3 requeridos.
  bool get isComplete =>
      destinationArea.trim().isNotEmpty &&
      street.trim().isNotEmpty &&
      postalCode.trim().isNotEmpty;

  /// Para mostrar en una sola línea en el header del perfil.
  String get summary {
    final parts = <String>[];
    if (street.trim().isNotEmpty) parts.add(street);
    if (department != null && department!.trim().isNotEmpty) {
      parts.add('Dpto ${department!}');
    }
    if (floor != null && floor!.trim().isNotEmpty) parts.add('Piso ${floor!}');
    if (postalCode.trim().isNotEmpty) parts.add('CP $postalCode');
    return parts.join(' · ');
  }

  UserLocation copyWith({
    String? destinationArea,
    String? street,
    String? postalCode,
    String? department,
    String? floor,
  }) =>
      UserLocation(
        destinationArea: destinationArea ?? this.destinationArea,
        street: street ?? this.street,
        postalCode: postalCode ?? this.postalCode,
        department: department ?? this.department,
        floor: floor ?? this.floor,
      );
}
