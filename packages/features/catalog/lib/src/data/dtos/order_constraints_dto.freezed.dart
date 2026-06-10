// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_constraints_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderConstraintsDto {

 int? get maxQuantityPerOrder;
/// Create a copy of OrderConstraintsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderConstraintsDtoCopyWith<OrderConstraintsDto> get copyWith => _$OrderConstraintsDtoCopyWithImpl<OrderConstraintsDto>(this as OrderConstraintsDto, _$identity);

  /// Serializes this OrderConstraintsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderConstraintsDto&&(identical(other.maxQuantityPerOrder, maxQuantityPerOrder) || other.maxQuantityPerOrder == maxQuantityPerOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxQuantityPerOrder);

@override
String toString() {
  return 'OrderConstraintsDto(maxQuantityPerOrder: $maxQuantityPerOrder)';
}


}

/// @nodoc
abstract mixin class $OrderConstraintsDtoCopyWith<$Res>  {
  factory $OrderConstraintsDtoCopyWith(OrderConstraintsDto value, $Res Function(OrderConstraintsDto) _then) = _$OrderConstraintsDtoCopyWithImpl;
@useResult
$Res call({
 int? maxQuantityPerOrder
});




}
/// @nodoc
class _$OrderConstraintsDtoCopyWithImpl<$Res>
    implements $OrderConstraintsDtoCopyWith<$Res> {
  _$OrderConstraintsDtoCopyWithImpl(this._self, this._then);

  final OrderConstraintsDto _self;
  final $Res Function(OrderConstraintsDto) _then;

/// Create a copy of OrderConstraintsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxQuantityPerOrder = freezed,}) {
  return _then(_self.copyWith(
maxQuantityPerOrder: freezed == maxQuantityPerOrder ? _self.maxQuantityPerOrder : maxQuantityPerOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderConstraintsDto].
extension OrderConstraintsDtoPatterns on OrderConstraintsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderConstraintsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderConstraintsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderConstraintsDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderConstraintsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderConstraintsDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderConstraintsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? maxQuantityPerOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderConstraintsDto() when $default != null:
return $default(_that.maxQuantityPerOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? maxQuantityPerOrder)  $default,) {final _that = this;
switch (_that) {
case _OrderConstraintsDto():
return $default(_that.maxQuantityPerOrder);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? maxQuantityPerOrder)?  $default,) {final _that = this;
switch (_that) {
case _OrderConstraintsDto() when $default != null:
return $default(_that.maxQuantityPerOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderConstraintsDto implements OrderConstraintsDto {
  const _OrderConstraintsDto({this.maxQuantityPerOrder});
  factory _OrderConstraintsDto.fromJson(Map<String, dynamic> json) => _$OrderConstraintsDtoFromJson(json);

@override final  int? maxQuantityPerOrder;

/// Create a copy of OrderConstraintsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderConstraintsDtoCopyWith<_OrderConstraintsDto> get copyWith => __$OrderConstraintsDtoCopyWithImpl<_OrderConstraintsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderConstraintsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderConstraintsDto&&(identical(other.maxQuantityPerOrder, maxQuantityPerOrder) || other.maxQuantityPerOrder == maxQuantityPerOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxQuantityPerOrder);

@override
String toString() {
  return 'OrderConstraintsDto(maxQuantityPerOrder: $maxQuantityPerOrder)';
}


}

/// @nodoc
abstract mixin class _$OrderConstraintsDtoCopyWith<$Res> implements $OrderConstraintsDtoCopyWith<$Res> {
  factory _$OrderConstraintsDtoCopyWith(_OrderConstraintsDto value, $Res Function(_OrderConstraintsDto) _then) = __$OrderConstraintsDtoCopyWithImpl;
@override @useResult
$Res call({
 int? maxQuantityPerOrder
});




}
/// @nodoc
class __$OrderConstraintsDtoCopyWithImpl<$Res>
    implements _$OrderConstraintsDtoCopyWith<$Res> {
  __$OrderConstraintsDtoCopyWithImpl(this._self, this._then);

  final _OrderConstraintsDto _self;
  final $Res Function(_OrderConstraintsDto) _then;

/// Create a copy of OrderConstraintsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxQuantityPerOrder = freezed,}) {
  return _then(_OrderConstraintsDto(
maxQuantityPerOrder: freezed == maxQuantityPerOrder ? _self.maxQuantityPerOrder : maxQuantityPerOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
