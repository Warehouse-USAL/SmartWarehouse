import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/order_timestamps_dto.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_line_item_dto.dart';

part 'order_tracking_item_dto.freezed.dart';
part 'order_tracking_item_dto.g.dart';

@freezed
sealed class OrderTrackingItemDto with _$OrderTrackingItemDto {
  const factory OrderTrackingItemDto({
    required String id,
    required String status,
    @Default([]) List<OrderTrackingLineItemDto> items,
    /// Algunas respuestas legacy lo mandan en root, hoy va dentro de
    /// `timestamps.createdAt`. Lo dejamos como fallback.
    String? createdAt,
    OrderTimestampsDto? timestamps,
  }) = _OrderTrackingItemDto;

  factory OrderTrackingItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingItemDtoFromJson(json);
}
