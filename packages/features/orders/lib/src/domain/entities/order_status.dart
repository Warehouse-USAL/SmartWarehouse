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
