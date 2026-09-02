import 'package:catalog/catalog.dart';

/// Construye un [Money] con defaults razonables.
///
/// `amount` está en centavos (minor units), igual que el contrato del backend.
/// El default de 1000 = $10,00 evita el caso degenerado de 0, que esconde
/// bugs de multiplicación y suma.
Money aMoney({
  int amount = 1000,
  String currency = 'ARS',
  bool? taxIncluded,
}) =>
    Money(amount: amount, currency: currency, taxIncluded: taxIncluded);
