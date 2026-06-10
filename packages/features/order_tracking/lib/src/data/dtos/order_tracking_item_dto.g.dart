// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracking_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderTrackingItemDto _$OrderTrackingItemDtoFromJson(
  Map<String, dynamic> json,
) => _OrderTrackingItemDto(
  id: json['id'] as String,
  status: json['status'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => OrderTrackingLineItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$OrderTrackingItemDtoToJson(
  _OrderTrackingItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'created_at': instance.createdAt,
};
