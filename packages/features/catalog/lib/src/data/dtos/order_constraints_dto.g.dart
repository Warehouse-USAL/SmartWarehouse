// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_constraints_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderConstraintsDto _$OrderConstraintsDtoFromJson(Map<String, dynamic> json) =>
    _OrderConstraintsDto(
      maxQuantityPerOrder: (json['max_quantity_per_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderConstraintsDtoToJson(
  _OrderConstraintsDto instance,
) => <String, dynamic>{'max_quantity_per_order': instance.maxQuantityPerOrder};
