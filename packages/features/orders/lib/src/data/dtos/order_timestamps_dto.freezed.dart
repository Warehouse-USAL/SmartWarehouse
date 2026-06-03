// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_timestamps_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderTimestampsDto {

 String? get createdAt; String? get startedAt; String? get completedAt;
/// Create a copy of OrderTimestampsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTimestampsDtoCopyWith<OrderTimestampsDto> get copyWith => _$OrderTimestampsDtoCopyWithImpl<OrderTimestampsDto>(this as OrderTimestampsDto, _$identity);

  /// Serializes this OrderTimestampsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTimestampsDto&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,startedAt,completedAt);

@override
String toString() {
  return 'OrderTimestampsDto(createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $OrderTimestampsDtoCopyWith<$Res>  {
  factory $OrderTimestampsDtoCopyWith(OrderTimestampsDto value, $Res Function(OrderTimestampsDto) _then) = _$OrderTimestampsDtoCopyWithImpl;
@useResult
$Res call({
 String? createdAt, String? startedAt, String? completedAt
});




}
/// @nodoc
class _$OrderTimestampsDtoCopyWithImpl<$Res>
    implements $OrderTimestampsDtoCopyWith<$Res> {
  _$OrderTimestampsDtoCopyWithImpl(this._self, this._then);

  final OrderTimestampsDto _self;
  final $Res Function(OrderTimestampsDto) _then;

/// Create a copy of OrderTimestampsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTimestampsDto].
extension OrderTimestampsDtoPatterns on OrderTimestampsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTimestampsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTimestampsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTimestampsDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderTimestampsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTimestampsDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTimestampsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? createdAt,  String? startedAt,  String? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTimestampsDto() when $default != null:
return $default(_that.createdAt,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? createdAt,  String? startedAt,  String? completedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderTimestampsDto():
return $default(_that.createdAt,_that.startedAt,_that.completedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? createdAt,  String? startedAt,  String? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderTimestampsDto() when $default != null:
return $default(_that.createdAt,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTimestampsDto implements OrderTimestampsDto {
  const _OrderTimestampsDto({this.createdAt, this.startedAt, this.completedAt});
  factory _OrderTimestampsDto.fromJson(Map<String, dynamic> json) => _$OrderTimestampsDtoFromJson(json);

@override final  String? createdAt;
@override final  String? startedAt;
@override final  String? completedAt;

/// Create a copy of OrderTimestampsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTimestampsDtoCopyWith<_OrderTimestampsDto> get copyWith => __$OrderTimestampsDtoCopyWithImpl<_OrderTimestampsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTimestampsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTimestampsDto&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,startedAt,completedAt);

@override
String toString() {
  return 'OrderTimestampsDto(createdAt: $createdAt, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderTimestampsDtoCopyWith<$Res> implements $OrderTimestampsDtoCopyWith<$Res> {
  factory _$OrderTimestampsDtoCopyWith(_OrderTimestampsDto value, $Res Function(_OrderTimestampsDto) _then) = __$OrderTimestampsDtoCopyWithImpl;
@override @useResult
$Res call({
 String? createdAt, String? startedAt, String? completedAt
});




}
/// @nodoc
class __$OrderTimestampsDtoCopyWithImpl<$Res>
    implements _$OrderTimestampsDtoCopyWith<$Res> {
  __$OrderTimestampsDtoCopyWithImpl(this._self, this._then);

  final _OrderTimestampsDto _self;
  final $Res Function(_OrderTimestampsDto) _then;

/// Create a copy of OrderTimestampsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,}) {
  return _then(_OrderTimestampsDto(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
