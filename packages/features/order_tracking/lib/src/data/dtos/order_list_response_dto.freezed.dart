// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_list_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderListResponseDto {

 List<OrderTrackingItemDto> get orders;
/// Create a copy of OrderListResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderListResponseDtoCopyWith<OrderListResponseDto> get copyWith => _$OrderListResponseDtoCopyWithImpl<OrderListResponseDto>(this as OrderListResponseDto, _$identity);

  /// Serializes this OrderListResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderListResponseDto&&const DeepCollectionEquality().equals(other.orders, orders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(orders));

@override
String toString() {
  return 'OrderListResponseDto(orders: $orders)';
}


}

/// @nodoc
abstract mixin class $OrderListResponseDtoCopyWith<$Res>  {
  factory $OrderListResponseDtoCopyWith(OrderListResponseDto value, $Res Function(OrderListResponseDto) _then) = _$OrderListResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<OrderTrackingItemDto> orders
});




}
/// @nodoc
class _$OrderListResponseDtoCopyWithImpl<$Res>
    implements $OrderListResponseDtoCopyWith<$Res> {
  _$OrderListResponseDtoCopyWithImpl(this._self, this._then);

  final OrderListResponseDto _self;
  final $Res Function(OrderListResponseDto) _then;

/// Create a copy of OrderListResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orders = null,}) {
  return _then(_self.copyWith(
orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderTrackingItemDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderListResponseDto].
extension OrderListResponseDtoPatterns on OrderListResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderListResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderListResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderListResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderListResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderListResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderListResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrderTrackingItemDto> orders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderListResponseDto() when $default != null:
return $default(_that.orders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrderTrackingItemDto> orders)  $default,) {final _that = this;
switch (_that) {
case _OrderListResponseDto():
return $default(_that.orders);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrderTrackingItemDto> orders)?  $default,) {final _that = this;
switch (_that) {
case _OrderListResponseDto() when $default != null:
return $default(_that.orders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderListResponseDto implements OrderListResponseDto {
  const _OrderListResponseDto({final  List<OrderTrackingItemDto> orders = const []}): _orders = orders;
  factory _OrderListResponseDto.fromJson(Map<String, dynamic> json) => _$OrderListResponseDtoFromJson(json);

 final  List<OrderTrackingItemDto> _orders;
@override@JsonKey() List<OrderTrackingItemDto> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}


/// Create a copy of OrderListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderListResponseDtoCopyWith<_OrderListResponseDto> get copyWith => __$OrderListResponseDtoCopyWithImpl<_OrderListResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderListResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderListResponseDto&&const DeepCollectionEquality().equals(other._orders, _orders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders));

@override
String toString() {
  return 'OrderListResponseDto(orders: $orders)';
}


}

/// @nodoc
abstract mixin class _$OrderListResponseDtoCopyWith<$Res> implements $OrderListResponseDtoCopyWith<$Res> {
  factory _$OrderListResponseDtoCopyWith(_OrderListResponseDto value, $Res Function(_OrderListResponseDto) _then) = __$OrderListResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<OrderTrackingItemDto> orders
});




}
/// @nodoc
class __$OrderListResponseDtoCopyWithImpl<$Res>
    implements _$OrderListResponseDtoCopyWith<$Res> {
  __$OrderListResponseDtoCopyWithImpl(this._self, this._then);

  final _OrderListResponseDto _self;
  final $Res Function(_OrderListResponseDto) _then;

/// Create a copy of OrderListResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orders = null,}) {
  return _then(_OrderListResponseDto(
orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderTrackingItemDto>,
  ));
}


}

// dart format on
