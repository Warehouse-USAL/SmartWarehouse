// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderListResponseDto _$OrderListResponseDtoFromJson(
  Map<String, dynamic> json,
) => _OrderListResponseDto(
  orders:
      (json['orders'] as List<dynamic>?)
          ?.map((e) => OrderTrackingItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderListResponseDtoToJson(
  _OrderListResponseDto instance,
) => <String, dynamic>{
  'orders': instance.orders.map((e) => e.toJson()).toList(),
};
