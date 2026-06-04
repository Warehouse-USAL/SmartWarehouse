// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    _PaginationDto(
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      totalElements: (json['total_elements'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PaginationDtoToJson(_PaginationDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'size': instance.size,
      'total_elements': instance.totalElements,
      'total_pages': instance.totalPages,
    };
