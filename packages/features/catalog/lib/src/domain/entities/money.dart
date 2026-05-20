/// Money value object alineado al contrato.
///
/// `amount` se expresa en minor units (centavos). El contrato usa tanto
/// `amount` (en `/products`) como `amount_cents` (en `/products/{id}`); ambos
/// representan el mismo valor en centavos.
class Money {
  const Money({
    required this.amount,
    required this.currency,
    this.taxIncluded,
  });

  /// Monto en centavos (minor units).
  final int amount;

  /// ISO-4217 code (ej: "ARS").
  final String currency;

  /// Solo viene en el endpoint de detalle.
  final bool? taxIncluded;

  double get major => amount / 100;

  Money operator *(int factor) =>
      Money(amount: amount * factor, currency: currency, taxIncluded: taxIncluded);

  Money operator +(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('No se pueden sumar montos de monedas distintas: $currency vs ${other.currency}');
    }
    return Money(amount: amount + other.amount, currency: currency, taxIncluded: taxIncluded);
  }

  static Money zero(String currency) => Money(amount: 0, currency: currency);

  /// Formato de display tipo `$49.999` o `$49.999,90`. Devuelve sin decimales
  /// cuando los centavos son 0.
  String get formatted {
    final whole = amount ~/ 100;
    final cents = amount % 100;
    final wholeStr = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < wholeStr.length; i++) {
      final fromRight = wholeStr.length - i;
      buf.write(wholeStr[i]);
      if (fromRight > 1 && fromRight % 3 == 1) buf.write('.');
    }
    if (cents == 0) return '\$$buf';
    return '\$$buf,${cents.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => 'Money($amount $currency)';
}
