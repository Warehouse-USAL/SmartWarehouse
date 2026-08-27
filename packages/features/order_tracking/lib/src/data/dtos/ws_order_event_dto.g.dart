// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_order_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WsOrderEventDto _$WsOrderEventDtoFromJson(Map<String, dynamic> json) =>
    _WsOrderEventDto(
      event: json['event'] as String,
      payload: WsOrderPayloadDto.fromJson(
        json['payload'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WsOrderEventDtoToJson(_WsOrderEventDto instance) =>
    <String, dynamic>{
      'event': instance.event,
      'payload': instance.payload.toJson(),
    };
