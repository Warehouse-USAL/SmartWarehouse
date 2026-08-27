import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_tracking_line_item_dto.freezed.dart';
part 'order_tracking_line_item_dto.g.dart';

@freezed
sealed class OrderTrackingLineItemDto with _$OrderTrackingLineItemDto {
  const factory OrderTrackingLineItemDto({
    required String productId,
    String? name,
    @Default(0) int quantity,
  }) = _OrderTrackingLineItemDto;

  factory OrderTrackingLineItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingLineItemDtoFromJson(json);
}
