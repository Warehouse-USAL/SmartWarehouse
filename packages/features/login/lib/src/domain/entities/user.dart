/// Usuario autenticado. Estructura del contrato `POST /auth/login`:
/// `{ id, name, email, role }`.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;

  /// Rol del usuario (ej: "operator", "admin"). String libre del backend.
  final String role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, $role)';
}
