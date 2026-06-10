import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_location_dto.freezed.dart';
part 'product_location_dto.g.dart';

@freezed
sealed class ProductLocationDto with _$ProductLocationDto {
  const factory ProductLocationDto({
    String? idZone,
    String? idLine,
    String? idPosition,
    String? height,
  }) = _ProductLocationDto;

  factory ProductLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ProductLocationDtoFromJson(json);
}
