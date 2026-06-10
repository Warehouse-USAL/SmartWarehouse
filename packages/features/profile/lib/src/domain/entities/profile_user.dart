class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.bay,
    required this.openOrdersCount,
    required this.spentThisMonth,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String bay;
  final int openOrdersCount;
  final double spentThisMonth;

  String get avatarInitials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String get formattedSpent {
    final cents = (spentThisMonth * 100).round();
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    return '\$$dollars.${remainder.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProfileUser && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
