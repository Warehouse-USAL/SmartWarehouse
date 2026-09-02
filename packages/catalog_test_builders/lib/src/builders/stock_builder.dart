import 'package:catalog/catalog.dart';

/// Construye un [Stock] con defaults razonables.
///
/// El default de 10 disponibles deja el producto comprable sin estar en
/// stock bajo: los tests que necesitan agotado o bajo lo piden explícito.
Stock aStock({
  int available = 10,
  int? min,
  int? reserved,
  int? lowStockThreshold,
}) =>
    Stock(
      available: available,
      min: min,
      reserved: reserved,
      lowStockThreshold: lowStockThreshold,
    );
