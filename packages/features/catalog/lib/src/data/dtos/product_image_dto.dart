import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_image_dto.freezed.dart';
part 'product_image_dto.g.dart';

@freezed
sealed class ProductImageDto with _$ProductImageDto {
  const factory ProductImageDto({
    required String url,
    String? alt,
    @Default(false) bool isPrimary,
  }) = _ProductImageDto;

  factory ProductImageDto.fromJson(Map<String, dynamic> json) =>
      _$ProductImageDtoFromJson(json);
}
