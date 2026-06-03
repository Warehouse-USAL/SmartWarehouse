import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_request_dto.freezed.dart';
part 'create_order_request_dto.g.dart';

@freezed
sealed class CreateOrderRequestDto with _$CreateOrderRequestDto {
  const factory CreateOrderRequestDto({
    required List<CreateOrderItemDto> items,
    required String destinationArea,
  }) = _CreateOrderRequestDto;

  factory CreateOrderRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestDtoFromJson(json);
}

@freezed
sealed class CreateOrderItemDto with _$CreateOrderItemDto {
  const factory CreateOrderItemDto({
    required String productId,
    required int quantity,
  }) = _CreateOrderItemDto;

  factory CreateOrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderItemDtoFromJson(json);
}
