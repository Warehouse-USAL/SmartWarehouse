// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_detail_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderTrackingDetailResponseDto {

 OrderTrackingItemDto get order;
/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingDetailResponseDtoCopyWith<OrderTrackingDetailResponseDto> get copyWith => _$OrderTrackingDetailResponseDtoCopyWithImpl<OrderTrackingDetailResponseDto>(this as OrderTrackingDetailResponseDto, _$identity);

  /// Serializes this OrderTrackingDetailResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackingDetailResponseDto&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'OrderTrackingDetailResponseDto(order: $order)';
}


}

/// @nodoc
abstract mixin class $OrderTrackingDetailResponseDtoCopyWith<$Res>  {
  factory $OrderTrackingDetailResponseDtoCopyWith(OrderTrackingDetailResponseDto value, $Res Function(OrderTrackingDetailResponseDto) _then) = _$OrderTrackingDetailResponseDtoCopyWithImpl;
@useResult
$Res call({
 OrderTrackingItemDto order
});


$OrderTrackingItemDtoCopyWith<$Res> get order;

}
/// @nodoc
class _$OrderTrackingDetailResponseDtoCopyWithImpl<$Res>
    implements $OrderTrackingDetailResponseDtoCopyWith<$Res> {
  _$OrderTrackingDetailResponseDtoCopyWithImpl(this._self, this._then);

  final OrderTrackingDetailResponseDto _self;
  final $Res Function(OrderTrackingDetailResponseDto) _then;

/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderTrackingItemDto,
  ));
}
/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderTrackingItemDtoCopyWith<$Res> get order {
  
  return $OrderTrackingItemDtoCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderTrackingDetailResponseDto].
extension OrderTrackingDetailResponseDtoPatterns on OrderTrackingDetailResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTrackingDetailResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTrackingDetailResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTrackingDetailResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderTrackingItemDto order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto() when $default != null:
return $default(_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderTrackingItemDto order)  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto():
return $default(_that.order);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderTrackingItemDto order)?  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingDetailResponseDto() when $default != null:
return $default(_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTrackingDetailResponseDto implements OrderTrackingDetailResponseDto {
  const _OrderTrackingDetailResponseDto({required this.order});
  factory _OrderTrackingDetailResponseDto.fromJson(Map<String, dynamic> json) => _$OrderTrackingDetailResponseDtoFromJson(json);

@override final  OrderTrackingItemDto order;

/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingDetailResponseDtoCopyWith<_OrderTrackingDetailResponseDto> get copyWith => __$OrderTrackingDetailResponseDtoCopyWithImpl<_OrderTrackingDetailResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTrackingDetailResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTrackingDetailResponseDto&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'OrderTrackingDetailResponseDto(order: $order)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingDetailResponseDtoCopyWith<$Res> implements $OrderTrackingDetailResponseDtoCopyWith<$Res> {
  factory _$OrderTrackingDetailResponseDtoCopyWith(_OrderTrackingDetailResponseDto value, $Res Function(_OrderTrackingDetailResponseDto) _then) = __$OrderTrackingDetailResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 OrderTrackingItemDto order
});


@override $OrderTrackingItemDtoCopyWith<$Res> get order;

}
/// @nodoc
class __$OrderTrackingDetailResponseDtoCopyWithImpl<$Res>
    implements _$OrderTrackingDetailResponseDtoCopyWith<$Res> {
  __$OrderTrackingDetailResponseDtoCopyWithImpl(this._self, this._then);

  final _OrderTrackingDetailResponseDto _self;
  final $Res Function(_OrderTrackingDetailResponseDto) _then;

/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,}) {
  return _then(_OrderTrackingDetailResponseDto(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderTrackingItemDto,
  ));
}

/// Create a copy of OrderTrackingDetailResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderTrackingItemDtoCopyWith<$Res> get order {
  
  return $OrderTrackingItemDtoCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}

// dart format on
