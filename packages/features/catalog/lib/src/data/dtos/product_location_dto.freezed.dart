// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductLocationDto {

 String? get idZone; String? get idLine; String? get idPosition; String? get height;
/// Create a copy of ProductLocationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductLocationDtoCopyWith<ProductLocationDto> get copyWith => _$ProductLocationDtoCopyWithImpl<ProductLocationDto>(this as ProductLocationDto, _$identity);

  /// Serializes this ProductLocationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductLocationDto&&(identical(other.idZone, idZone) || other.idZone == idZone)&&(identical(other.idLine, idLine) || other.idLine == idLine)&&(identical(other.idPosition, idPosition) || other.idPosition == idPosition)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idZone,idLine,idPosition,height);

@override
String toString() {
  return 'ProductLocationDto(idZone: $idZone, idLine: $idLine, idPosition: $idPosition, height: $height)';
}


}

/// @nodoc
abstract mixin class $ProductLocationDtoCopyWith<$Res>  {
  factory $ProductLocationDtoCopyWith(ProductLocationDto value, $Res Function(ProductLocationDto) _then) = _$ProductLocationDtoCopyWithImpl;
@useResult
$Res call({
 String? idZone, String? idLine, String? idPosition, String? height
});




}
/// @nodoc
class _$ProductLocationDtoCopyWithImpl<$Res>
    implements $ProductLocationDtoCopyWith<$Res> {
  _$ProductLocationDtoCopyWithImpl(this._self, this._then);

  final ProductLocationDto _self;
  final $Res Function(ProductLocationDto) _then;

/// Create a copy of ProductLocationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idZone = freezed,Object? idLine = freezed,Object? idPosition = freezed,Object? height = freezed,}) {
  return _then(_self.copyWith(
idZone: freezed == idZone ? _self.idZone : idZone // ignore: cast_nullable_to_non_nullable
as String?,idLine: freezed == idLine ? _self.idLine : idLine // ignore: cast_nullable_to_non_nullable
as String?,idPosition: freezed == idPosition ? _self.idPosition : idPosition // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductLocationDto].
extension ProductLocationDtoPatterns on ProductLocationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductLocationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductLocationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductLocationDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductLocationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductLocationDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductLocationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? idZone,  String? idLine,  String? idPosition,  String? height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductLocationDto() when $default != null:
return $default(_that.idZone,_that.idLine,_that.idPosition,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? idZone,  String? idLine,  String? idPosition,  String? height)  $default,) {final _that = this;
switch (_that) {
case _ProductLocationDto():
return $default(_that.idZone,_that.idLine,_that.idPosition,_that.height);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? idZone,  String? idLine,  String? idPosition,  String? height)?  $default,) {final _that = this;
switch (_that) {
case _ProductLocationDto() when $default != null:
return $default(_that.idZone,_that.idLine,_that.idPosition,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductLocationDto implements ProductLocationDto {
  const _ProductLocationDto({this.idZone, this.idLine, this.idPosition, this.height});
  factory _ProductLocationDto.fromJson(Map<String, dynamic> json) => _$ProductLocationDtoFromJson(json);

@override final  String? idZone;
@override final  String? idLine;
@override final  String? idPosition;
@override final  String? height;

/// Create a copy of ProductLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductLocationDtoCopyWith<_ProductLocationDto> get copyWith => __$ProductLocationDtoCopyWithImpl<_ProductLocationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductLocationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductLocationDto&&(identical(other.idZone, idZone) || other.idZone == idZone)&&(identical(other.idLine, idLine) || other.idLine == idLine)&&(identical(other.idPosition, idPosition) || other.idPosition == idPosition)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,idZone,idLine,idPosition,height);

@override
String toString() {
  return 'ProductLocationDto(idZone: $idZone, idLine: $idLine, idPosition: $idPosition, height: $height)';
}


}

/// @nodoc
abstract mixin class _$ProductLocationDtoCopyWith<$Res> implements $ProductLocationDtoCopyWith<$Res> {
  factory _$ProductLocationDtoCopyWith(_ProductLocationDto value, $Res Function(_ProductLocationDto) _then) = __$ProductLocationDtoCopyWithImpl;
@override @useResult
$Res call({
 String? idZone, String? idLine, String? idPosition, String? height
});




}
/// @nodoc
class __$ProductLocationDtoCopyWithImpl<$Res>
    implements _$ProductLocationDtoCopyWith<$Res> {
  __$ProductLocationDtoCopyWithImpl(this._self, this._then);

  final _ProductLocationDto _self;
  final $Res Function(_ProductLocationDto) _then;

/// Create a copy of ProductLocationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idZone = freezed,Object? idLine = freezed,Object? idPosition = freezed,Object? height = freezed,}) {
  return _then(_ProductLocationDto(
idZone: freezed == idZone ? _self.idZone : idZone // ignore: cast_nullable_to_non_nullable
as String?,idLine: freezed == idLine ? _self.idLine : idLine // ignore: cast_nullable_to_non_nullable
as String?,idPosition: freezed == idPosition ? _self.idPosition : idPosition // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
