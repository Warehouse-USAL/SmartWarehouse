import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/ws_order_payload_dto.dart';

part 'ws_order_event_dto.freezed.dart';
part 'ws_order_event_dto.g.dart';

@freezed
sealed class WsOrderEventDto with _$WsOrderEventDto {
  const factory WsOrderEventDto({
    required String event,
    required WsOrderPayloadDto payload,
  }) = _WsOrderEventDto;

  factory WsOrderEventDto.fromJson(Map<String, dynamic> json) =>
      _$WsOrderEventDtoFromJson(json);
}
