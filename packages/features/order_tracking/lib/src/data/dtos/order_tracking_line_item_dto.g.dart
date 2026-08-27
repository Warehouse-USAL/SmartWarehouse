// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracking_line_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderTrackingLineItemDto _$OrderTrackingLineItemDtoFromJson(
  Map<String, dynamic> json,
) => _OrderTrackingLineItemDto(
  productId: json['product_id'] as String,
  name: json['name'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderTrackingLineItemDtoToJson(
  _OrderTrackingLineItemDto instance,
) => <String, dynamic>{
  'product_id': instance.productId,
  'name': instance.name,
  'quantity': instance.quantity,
};
