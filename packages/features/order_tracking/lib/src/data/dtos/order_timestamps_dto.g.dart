// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_timestamps_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderTimestampsDto _$OrderTimestampsDtoFromJson(Map<String, dynamic> json) =>
    _OrderTimestampsDto(
      createdAt: json['created_at'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );

Map<String, dynamic> _$OrderTimestampsDtoToJson(_OrderTimestampsDto instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt,
      'started_at': instance.startedAt,
      'completed_at': instance.completedAt,
    };
