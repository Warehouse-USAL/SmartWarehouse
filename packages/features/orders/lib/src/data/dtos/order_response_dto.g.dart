// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderResponseDto _$OrderResponseDtoFromJson(Map<String, dynamic> json) =>
    _OrderResponseDto(
      order: OrderDto.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderResponseDtoToJson(_OrderResponseDto instance) =>
    <String, dynamic>{'order': instance.order.toJson()};
