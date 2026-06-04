// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductsPageDto _$ProductsPageDtoFromJson(Map<String, dynamic> json) =>
    _ProductsPageDto(
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pagination: json['pagination'] == null
          ? null
          : PaginationDto.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProductsPageDtoToJson(_ProductsPageDto instance) =>
    <String, dynamic>{
      'products': instance.products.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination?.toJson(),
    };
