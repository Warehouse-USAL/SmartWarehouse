import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_dto.freezed.dart';
part 'price_dto.g.dart';

@freezed
sealed class PriceDto with _$PriceDto {
  const factory PriceDto({
    @Default(0) int amountCents,
    @Default('ARS') String currency,
    bool? taxIncluded,
  }) = _PriceDto;

  factory PriceDto.fromJson(Map<String, dynamic> json) =>
      _$PriceDtoFromJson(json);
}
