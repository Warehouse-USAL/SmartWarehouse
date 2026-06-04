// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_order_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateOrderRequestDto _$CreateOrderRequestDtoFromJson(
  Map<String, dynamic> json,
) => _CreateOrderRequestDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => CreateOrderItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  destinationArea: json['destination_area'] as String,
);

Map<String, dynamic> _$CreateOrderRequestDtoToJson(
  _CreateOrderRequestDto instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'destination_area': instance.destinationArea,
};

_CreateOrderItemDto _$CreateOrderItemDtoFromJson(Map<String, dynamic> json) =>
    _CreateOrderItemDto(
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$CreateOrderItemDtoToJson(_CreateOrderItemDto instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
    };
