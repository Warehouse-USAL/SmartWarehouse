import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_dto.freezed.dart';
part 'stock_dto.g.dart';

@freezed
sealed class StockDto with _$StockDto {
  const factory StockDto({
    @Default(0) int available,
    int? reserved,
    int? min,
    int? lowStockThreshold,
  }) = _StockDto;

  factory StockDto.fromJson(Map<String, dynamic> json) =>
      _$StockDtoFromJson(json);
}
