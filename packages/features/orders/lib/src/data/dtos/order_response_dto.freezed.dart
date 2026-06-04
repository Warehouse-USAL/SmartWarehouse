// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderResponseDto {

 OrderDto get order;
/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderResponseDtoCopyWith<OrderResponseDto> get copyWith => _$OrderResponseDtoCopyWithImpl<OrderResponseDto>(this as OrderResponseDto, _$identity);

  /// Serializes this OrderResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderResponseDto&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'OrderResponseDto(order: $order)';
}


}

/// @nodoc
abstract mixin class $OrderResponseDtoCopyWith<$Res>  {
  factory $OrderResponseDtoCopyWith(OrderResponseDto value, $Res Function(OrderResponseDto) _then) = _$OrderResponseDtoCopyWithImpl;
@useResult
$Res call({
 OrderDto order
});


$OrderDtoCopyWith<$Res> get order;

}
/// @nodoc
class _$OrderResponseDtoCopyWithImpl<$Res>
    implements $OrderResponseDtoCopyWith<$Res> {
  _$OrderResponseDtoCopyWithImpl(this._self, this._then);

  final OrderResponseDto _self;
  final $Res Function(OrderResponseDto) _then;

/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? order = null,}) {
  return _then(_self.copyWith(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderDto,
  ));
}
/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDtoCopyWith<$Res> get order {
  
  return $OrderDtoCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderResponseDto].
extension OrderResponseDtoPatterns on OrderResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderDto order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderResponseDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderDto order)  $default,) {final _that = this;
switch (_that) {
case _OrderResponseDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderDto order)?  $default,) {final _that = this;
switch (_that) {
case _OrderResponseDto() when $default != null:
return $default(_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderResponseDto implements OrderResponseDto {
  const _OrderResponseDto({required this.order});
  factory _OrderResponseDto.fromJson(Map<String, dynamic> json) => _$OrderResponseDtoFromJson(json);

@override final  OrderDto order;

/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderResponseDtoCopyWith<_OrderResponseDto> get copyWith => __$OrderResponseDtoCopyWithImpl<_OrderResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderResponseDto&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,order);

@override
String toString() {
  return 'OrderResponseDto(order: $order)';
}


}

/// @nodoc
abstract mixin class _$OrderResponseDtoCopyWith<$Res> implements $OrderResponseDtoCopyWith<$Res> {
  factory _$OrderResponseDtoCopyWith(_OrderResponseDto value, $Res Function(_OrderResponseDto) _then) = __$OrderResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 OrderDto order
});


@override $OrderDtoCopyWith<$Res> get order;

}
/// @nodoc
class __$OrderResponseDtoCopyWithImpl<$Res>
    implements _$OrderResponseDtoCopyWith<$Res> {
  __$OrderResponseDtoCopyWithImpl(this._self, this._then);

  final _OrderResponseDto _self;
  final $Res Function(_OrderResponseDto) _then;

/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? order = null,}) {
  return _then(_OrderResponseDto(
order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as OrderDto,
  ));
}

/// Create a copy of OrderResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDtoCopyWith<$Res> get order {
  
  return $OrderDtoCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}

// dart format on
