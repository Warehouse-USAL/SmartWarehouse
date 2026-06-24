import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_order_payload_dto.freezed.dart';
part 'ws_order_payload_dto.g.dart';

/// Payload del evento `order.updated` del back.
///
/// El back manda la `OrderResponse` completa adentro de `payload`, así que el
/// id viene como `id` (NO `order_id`). Solo necesitamos id + status acá para
/// disparar el refresh — el resto se obtiene haciendo GET /orders/{id}.
@freezed
sealed class WsOrderPayloadDto with _$WsOrderPayloadDto {
  const factory WsOrderPayloadDto({
    required String id,
    required String status,
  }) = _WsOrderPayloadDto;

  factory WsOrderPayloadDto.fromJson(Map<String, dynamic> json) =>
      _$WsOrderPayloadDtoFromJson(json);
}
