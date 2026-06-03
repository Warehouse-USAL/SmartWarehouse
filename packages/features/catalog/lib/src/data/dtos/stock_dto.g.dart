// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockDto _$StockDtoFromJson(Map<String, dynamic> json) => _StockDto(
  available: (json['available'] as num?)?.toInt() ?? 0,
  reserved: (json['reserved'] as num?)?.toInt(),
  min: (json['min'] as num?)?.toInt(),
  lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt(),
);

Map<String, dynamic> _$StockDtoToJson(_StockDto instance) => <String, dynamic>{
  'available': instance.available,
  'reserved': instance.reserved,
  'min': instance.min,
  'low_stock_threshold': instance.lowStockThreshold,
};
