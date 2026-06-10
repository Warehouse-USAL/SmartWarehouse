// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PriceDto _$PriceDtoFromJson(Map<String, dynamic> json) => _PriceDto(
  amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
  currency: json['currency'] as String? ?? 'ARS',
  taxIncluded: json['tax_included'] as bool?,
);

Map<String, dynamic> _$PriceDtoToJson(_PriceDto instance) => <String, dynamic>{
  'amount_cents': instance.amountCents,
  'currency': instance.currency,
  'tax_included': instance.taxIncluded,
};
