import 'package:freezed_annotation/freezed_annotation.dart';
import  'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';

part 'order_tracking_detail_response_dto.freezed.dart';
part 'order_tracking_detail_response_dto.g.dart';

@freezed
sealed class OrderTrackingDetailResponseDto with _$OrderTrackingDetailResponseDto {
  const factory OrderTrackingDetailResponseDto({
    required OrderTrackingItemDto order,
  }) = _OrderTrackingDetailResponseDto;

  factory OrderTrackingDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingDetailResponseDtoFromJson(json);
}
