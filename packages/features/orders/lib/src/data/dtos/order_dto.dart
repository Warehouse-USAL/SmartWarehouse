import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:orders/src/data/dtos/order_item_dto.dart';
import 'package:orders/src/data/dtos/order_timestamps_dto.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

@freezed
sealed class OrderDto with _$OrderDto {
  const factory OrderDto({
    required String id,
    required String status,
    String? requestedByUserId,
    @Default([]) List<OrderItemDto> items,
    String? destinationArea,
    String? assignedVehicleId,
    OrderTimestampsDto? timestamps,
    String? cancelReason,
  }) = _OrderDto;

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
}
