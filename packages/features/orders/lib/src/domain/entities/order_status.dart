enum OrderStatus { pending, inProgress, completed, cancelled }

/// Reglas y label del estado en un solo lugar — antes el switch del label
/// estaba duplicado cuatro veces entre order_tracking y profile.
extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Pendiente',
    OrderStatus.inProgress => 'En progreso',
    OrderStatus.completed => 'Completado',
    OrderStatus.cancelled => 'Cancelado',
  };

  /// Una orden puede cancelarse mientras no esté terminada.
  bool get isCancellable =>
      this == OrderStatus.pending || this == OrderStatus.inProgress;

  /// "Pedir de nuevo" aplica a órdenes que ya no van a moverse.
  bool get canReorder =>
      this == OrderStatus.completed || this == OrderStatus.cancelled;
}

/// Traduce el `cancel_reason` del back a un texto apto para mostrar.
///
/// - Códigos conocidos (UPPER_SNAKE) → copy en castellano.
/// - Códigos desconocidos o `null` → `null`: preferimos no mostrar nada antes
///   que exponer un código crudo del backend al usuario.
/// - Texto libre (p. ej. un motivo ya redactado, como el que setea la app al
///   cancelar manualmente) → se devuelve tal cual, ya es legible.
String? humanizeCancelReason(String? reason) {
  final trimmed = reason?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  const known = <String, String>{
    'INSUFFICIENT_STOCK': 'Cancelada por falta de stock',
  };
  final translated = known[trimmed];
  if (translated != null) return translated;

  // Con forma de código pero no lo conocemos: mejor sin texto.
  final looksLikeCode = RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed);
  return looksLikeCode ? null : trimmed;
}
