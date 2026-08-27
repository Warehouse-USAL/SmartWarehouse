import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_order_request_dto.freezed.dart';
part 'create_order_request_dto.g.dart';

@freezed
sealed class CreateOrderRequestDto with _$CreateOrderRequestDto {
  const factory CreateOrderRequestDto({
    required List<CreateOrderItemDto> items,
    required String destinationArea,
    required AddressDto address,
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

/// Dirección de entrega de la orden. `street` y `postalCode` son requeridos
/// por el back (PR #55 / #63 — MISSING_ADDRESS_STREET, MISSING_ADDRESS_POSTAL_CODE).
/// `department` y `floor` son opcionales.
@freezed
sealed class AddressDto with _$AddressDto {
  const factory AddressDto({
    required String street,
    required String postalCode,
    String? department,
    String? floor,
  }) = _AddressDto;

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);
}
