// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_tracking_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderTrackingDetailResponseDto _$OrderTrackingDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => _OrderTrackingDetailResponseDto(
  order: OrderTrackingItemDto.fromJson(json['order'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OrderTrackingDetailResponseDtoToJson(
  _OrderTrackingDetailResponseDto instance,
) => <String, dynamic>{'order': instance.order.toJson()};
