import 'package:catalog/catalog.dart';
import 'package:profile/src/domain/entities/user_address.dart';

class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.openOrdersCount,
    this.spentThisMonth,
    this.address,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final int openOrdersCount;

  /// Gastado en el mes en curso. `null` si no se pudo calcular de forma
  /// confiable (algún precio faltante o monedas mezcladas) — la UI muestra "—".
  final Money? spentThisMonth;

  /// Dirección guardada en el back (PATCH /users/me). null si el usuario
  /// no la configuró todavía.
  final UserAddress? address;

  String get avatarInitials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  /// Único formato de dinero de la app: `Money.formatted`.
  String get formattedSpent => spentThisMonth?.formatted ?? '—';

  ProfileUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    int? openOrdersCount,
    Money? spentThisMonth,
    bool clearSpent = false,
    UserAddress? address,
    bool clearAddress = false,
  }) =>
      ProfileUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        openOrdersCount: openOrdersCount ?? this.openOrdersCount,
        spentThisMonth: clearSpent ? null : (spentThisMonth ?? this.spentThisMonth),
        address: clearAddress ? null : (address ?? this.address),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProfileUser && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
