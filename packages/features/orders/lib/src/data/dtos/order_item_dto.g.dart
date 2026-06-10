// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) =>
    _OrderItemDto(
      productId: json['product_id'] as String,
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderItemDtoToJson(_OrderItemDto instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'sku': instance.sku,
      'name': instance.name,
      'quantity': instance.quantity,
    };
