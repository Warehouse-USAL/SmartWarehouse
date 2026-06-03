// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_image_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductImageDto _$ProductImageDtoFromJson(Map<String, dynamic> json) =>
    _ProductImageDto(
      url: json['url'] as String,
      alt: json['alt'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductImageDtoToJson(_ProductImageDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'alt': instance.alt,
      'is_primary': instance.isPrimary,
    };
