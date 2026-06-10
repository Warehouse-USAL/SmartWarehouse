import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_order_payload_dto.freezed.dart';
part 'ws_order_payload_dto.g.dart';

@freezed
sealed class WsOrderPayloadDto with _$WsOrderPayloadDto {
  const factory WsOrderPayloadDto({
    required String orderId,
    required String status,
  }) = _WsOrderPayloadDto;

  factory WsOrderPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$WsOrderPayloadDtoFromJson(json);
}
