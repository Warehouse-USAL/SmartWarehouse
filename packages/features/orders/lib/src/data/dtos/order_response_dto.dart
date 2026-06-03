import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orders/src/data/dtos/order_dto.dart';

part 'order_response_dto.freezed.dart';
part 'order_response_dto.g.dart';

@freezed
sealed class OrderResponseDto with _$OrderResponseDto {
  const factory OrderResponseDto({
    required OrderDto order,
  }) = _OrderResponseDto;

  factory OrderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseDtoFromJson(json);
}
