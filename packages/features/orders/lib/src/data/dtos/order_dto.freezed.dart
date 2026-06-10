// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderDto {

 String get id; String get status; String? get requestedByUserId; List<OrderItemDto> get items; String? get destinationArea; String? get assignedVehicleId; OrderTimestampsDto? get timestamps; String? get cancelReason;
/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDtoCopyWith<OrderDto> get copyWith => _$OrderDtoCopyWithImpl<OrderDto>(this as OrderDto, _$identity);

  /// Serializes this OrderDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedByUserId, requestedByUserId) || other.requestedByUserId == requestedByUserId)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.destinationArea, destinationArea) || other.destinationArea == destinationArea)&&(identical(other.assignedVehicleId, assignedVehicleId) || other.assignedVehicleId == assignedVehicleId)&&(identical(other.timestamps, timestamps) || other.timestamps == timestamps)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,requestedByUserId,const DeepCollectionEquality().hash(items),destinationArea,assignedVehicleId,timestamps,cancelReason);

@override
String toString() {
  return 'OrderDto(id: $id, status: $status, requestedByUserId: $requestedByUserId, items: $items, destinationArea: $destinationArea, assignedVehicleId: $assignedVehicleId, timestamps: $timestamps, cancelReason: $cancelReason)';
}


}

/// @nodoc
abstract mixin class $OrderDtoCopyWith<$Res>  {
  factory $OrderDtoCopyWith(OrderDto value, $Res Function(OrderDto) _then) = _$OrderDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status, String? requestedByUserId, List<OrderItemDto> items, String? destinationArea, String? assignedVehicleId, OrderTimestampsDto? timestamps, String? cancelReason
});


$OrderTimestampsDtoCopyWith<$Res>? get timestamps;

}
/// @nodoc
class _$OrderDtoCopyWithImpl<$Res>
    implements $OrderDtoCopyWith<$Res> {
  _$OrderDtoCopyWithImpl(this._self, this._then);

  final OrderDto _self;
  final $Res Function(OrderDto) _then;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? requestedByUserId = freezed,Object? items = null,Object? destinationArea = freezed,Object? assignedVehicleId = freezed,Object? timestamps = freezed,Object? cancelReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requestedByUserId: freezed == requestedByUserId ? _self.requestedByUserId : requestedByUserId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemDto>,destinationArea: freezed == destinationArea ? _self.destinationArea : destinationArea // ignore: cast_nullable_to_non_nullable
as String?,assignedVehicleId: freezed == assignedVehicleId ? _self.assignedVehicleId : assignedVehicleId // ignore: cast_nullable_to_non_nullable
as String?,timestamps: freezed == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as OrderTimestampsDto?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderTimestampsDtoCopyWith<$Res>? get timestamps {
    if (_self.timestamps == null) {
    return null;
  }

  return $OrderTimestampsDtoCopyWith<$Res>(_self.timestamps!, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderDto].
extension OrderDtoPatterns on OrderDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderDto():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String? requestedByUserId,  List<OrderItemDto> items,  String? destinationArea,  String? assignedVehicleId,  OrderTimestampsDto? timestamps,  String? cancelReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that.id,_that.status,_that.requestedByUserId,_that.items,_that.destinationArea,_that.assignedVehicleId,_that.timestamps,_that.cancelReason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String? requestedByUserId,  List<OrderItemDto> items,  String? destinationArea,  String? assignedVehicleId,  OrderTimestampsDto? timestamps,  String? cancelReason)  $default,) {final _that = this;
switch (_that) {
case _OrderDto():
return $default(_that.id,_that.status,_that.requestedByUserId,_that.items,_that.destinationArea,_that.assignedVehicleId,_that.timestamps,_that.cancelReason);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String? requestedByUserId,  List<OrderItemDto> items,  String? destinationArea,  String? assignedVehicleId,  OrderTimestampsDto? timestamps,  String? cancelReason)?  $default,) {final _that = this;
switch (_that) {
case _OrderDto() when $default != null:
return $default(_that.id,_that.status,_that.requestedByUserId,_that.items,_that.destinationArea,_that.assignedVehicleId,_that.timestamps,_that.cancelReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDto implements OrderDto {
  const _OrderDto({required this.id, required this.status, this.requestedByUserId, final  List<OrderItemDto> items = const [], this.destinationArea, this.assignedVehicleId, this.timestamps, this.cancelReason}): _items = items;
  factory _OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);

@override final  String id;
@override final  String status;
@override final  String? requestedByUserId;
 final  List<OrderItemDto> _items;
@override@JsonKey() List<OrderItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? destinationArea;
@override final  String? assignedVehicleId;
@override final  OrderTimestampsDto? timestamps;
@override final  String? cancelReason;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDtoCopyWith<_OrderDto> get copyWith => __$OrderDtoCopyWithImpl<_OrderDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestedByUserId, requestedByUserId) || other.requestedByUserId == requestedByUserId)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.destinationArea, destinationArea) || other.destinationArea == destinationArea)&&(identical(other.assignedVehicleId, assignedVehicleId) || other.assignedVehicleId == assignedVehicleId)&&(identical(other.timestamps, timestamps) || other.timestamps == timestamps)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,requestedByUserId,const DeepCollectionEquality().hash(_items),destinationArea,assignedVehicleId,timestamps,cancelReason);

@override
String toString() {
  return 'OrderDto(id: $id, status: $status, requestedByUserId: $requestedByUserId, items: $items, destinationArea: $destinationArea, assignedVehicleId: $assignedVehicleId, timestamps: $timestamps, cancelReason: $cancelReason)';
}


}

/// @nodoc
abstract mixin class _$OrderDtoCopyWith<$Res> implements $OrderDtoCopyWith<$Res> {
  factory _$OrderDtoCopyWith(_OrderDto value, $Res Function(_OrderDto) _then) = __$OrderDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String? requestedByUserId, List<OrderItemDto> items, String? destinationArea, String? assignedVehicleId, OrderTimestampsDto? timestamps, String? cancelReason
});


@override $OrderTimestampsDtoCopyWith<$Res>? get timestamps;

}
/// @nodoc
class __$OrderDtoCopyWithImpl<$Res>
    implements _$OrderDtoCopyWith<$Res> {
  __$OrderDtoCopyWithImpl(this._self, this._then);

  final _OrderDto _self;
  final $Res Function(_OrderDto) _then;

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? requestedByUserId = freezed,Object? items = null,Object? destinationArea = freezed,Object? assignedVehicleId = freezed,Object? timestamps = freezed,Object? cancelReason = freezed,}) {
  return _then(_OrderDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requestedByUserId: freezed == requestedByUserId ? _self.requestedByUserId : requestedByUserId // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemDto>,destinationArea: freezed == destinationArea ? _self.destinationArea : destinationArea // ignore: cast_nullable_to_non_nullable
as String?,assignedVehicleId: freezed == assignedVehicleId ? _self.assignedVehicleId : assignedVehicleId // ignore: cast_nullable_to_non_nullable
as String?,timestamps: freezed == timestamps ? _self.timestamps : timestamps // ignore: cast_nullable_to_non_nullable
as OrderTimestampsDto?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OrderDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderTimestampsDtoCopyWith<$Res>? get timestamps {
    if (_self.timestamps == null) {
    return null;
  }

  return $OrderTimestampsDtoCopyWith<$Res>(_self.timestamps!, (value) {
    return _then(_self.copyWith(timestamps: value));
  });
}
}

// dart format on
