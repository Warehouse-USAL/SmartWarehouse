/// DTO de precio, con parsing manual (sin codegen) porque el contrato es
/// inconsistente entre endpoints: `/products` manda `amount` y
/// `/products/{id}` manda `amount_cents` — ambos en centavos. Un JSON de
/// precio sin monto o sin moneda es un error de contrato y se rechaza acá
/// (la UI ya muestra estado de error con "Reintentar"), en vez de caer en
/// silencio a $0 / moneda default y mostrar precios incorrectos.
class PriceDto {
  const PriceDto({
    this.amountCents = 0,
    this.currency = 'ARS',
    this.taxIncluded,
  });

  factory PriceDto.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount_cents'] ?? json['amount'];
    if (rawAmount is! num) {
      throw FormatException('price sin amount/amount_cents: $json');
    }
    final rawCurrency = json['currency'];
    if (rawCurrency is! String || rawCurrency.isEmpty) {
      throw FormatException('price sin currency: $json');
    }
    return PriceDto(
      amountCents: rawAmount.toInt(),
      currency: rawCurrency.toUpperCase(),
      taxIncluded: json['tax_included'] as bool?,
    );
  }

  final int amountCents;
  final String currency;
  final bool? taxIncluded;

  Map<String, dynamic> toJson() => {
        'amount_cents': amountCents,
        'currency': currency,
        'tax_included': taxIncluded,
      };
}
