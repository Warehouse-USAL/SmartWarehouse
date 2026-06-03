// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => _OrderDto(
  id: json['id'] as String,
  status: json['status'] as String,
  requestedByUserId: json['requested_by_user_id'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  destinationArea: json['destination_area'] as String?,
  assignedVehicleId: json['assigned_vehicle_id'] as String?,
  timestamps: json['timestamps'] == null
      ? null
      : OrderTimestampsDto.fromJson(json['timestamps'] as Map<String, dynamic>),
  cancelReason: json['cancel_reason'] as String?,
);

Map<String, dynamic> _$OrderDtoToJson(_OrderDto instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'requested_by_user_id': instance.requestedByUserId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'destination_area': instance.destinationArea,
  'assigned_vehicle_id': instance.assignedVehicleId,
  'timestamps': instance.timestamps?.toJson(),
  'cancel_reason': instance.cancelReason,
};
