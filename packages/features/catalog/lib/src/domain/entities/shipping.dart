class Shipping {
  const Shipping({
    required this.shipsToday,
    required this.cutoffTime,
    required this.pickupLocation,
  });

  final bool shipsToday;

  /// Formato "HH:mm" (ej: "16:00").
  final String cutoffTime;

  final String pickupLocation;
}
