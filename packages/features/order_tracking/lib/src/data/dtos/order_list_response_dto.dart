import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order_tracking/src/data/dtos/order_tracking_item_dto.dart';

part 'order_list_response_dto.freezed.dart';
part 'order_list_response_dto.g.dart';

@freezed
sealed class OrderListResponseDto with _$OrderListResponseDto {
  const factory OrderListResponseDto({
    @Default([]) List<OrderTrackingItemDto> orders,
  }) = _OrderListResponseDto;

  factory OrderListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseDtoFromJson(json);
}
