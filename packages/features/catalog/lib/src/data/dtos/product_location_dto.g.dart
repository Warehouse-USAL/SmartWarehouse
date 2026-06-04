// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProductLocationDto _$ProductLocationDtoFromJson(Map<String, dynamic> json) =>
    _ProductLocationDto(
      idZone: json['id_zone'] as String?,
      idLine: json['id_line'] as String?,
      idPosition: json['id_position'] as String?,
      height: json['height'] as String?,
    );

Map<String, dynamic> _$ProductLocationDtoToJson(_ProductLocationDto instance) =>
    <String, dynamic>{
      'id_zone': instance.idZone,
      'id_line': instance.idLine,
      'id_position': instance.idPosition,
      'height': instance.height,
    };
