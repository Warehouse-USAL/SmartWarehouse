import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_item_dto.freezed.dart';
part 'order_item_dto.g.dart';

@freezed
sealed class OrderItemDto with _$OrderItemDto {
  const factory OrderItemDto({
    required String productId,
    String? sku,
    String? name,
    @Default(0) int quantity,
  }) = _OrderItemDto;

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);
}
