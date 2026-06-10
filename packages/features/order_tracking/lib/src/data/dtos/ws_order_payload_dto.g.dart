// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_order_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WsOrderPayloadDto _$WsOrderPayloadDtoFromJson(Map<String, dynamic> json) =>
    _WsOrderPayloadDto(
      orderId: json['order_id'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$WsOrderPayloadDtoToJson(_WsOrderPayloadDto instance) =>
    <String, dynamic>{'order_id': instance.orderId, 'status': instance.status};
