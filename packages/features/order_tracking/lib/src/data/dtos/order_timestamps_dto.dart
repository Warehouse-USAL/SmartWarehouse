import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_timestamps_dto.freezed.dart';
part 'order_timestamps_dto.g.dart';

/// Bloque `timestamps` que el back devuelve dentro de cada orden
/// (`GET /orders/{id}` y `GET /orders`):
/// ```json
/// "timestamps": { "created_at": "...", "started_at": null, "completed_at": null }
/// ```
@freezed
sealed class OrderTimestampsDto with _$OrderTimestampsDto {
  const factory OrderTimestampsDto({
    String? createdAt,
    String? startedAt,
    String? completedAt,
  }) = _OrderTimestampsDto;

  factory OrderTimestampsDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTimestampsDtoFromJson(json);
}
