// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_image_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductImageDto {

 String get url; String? get alt; bool get isPrimary;
/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductImageDtoCopyWith<ProductImageDto> get copyWith => _$ProductImageDtoCopyWithImpl<ProductImageDto>(this as ProductImageDto, _$identity);

  /// Serializes this ProductImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductImageDto&&(identical(other.url, url) || other.url == url)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,alt,isPrimary);

@override
String toString() {
  return 'ProductImageDto(url: $url, alt: $alt, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $ProductImageDtoCopyWith<$Res>  {
  factory $ProductImageDtoCopyWith(ProductImageDto value, $Res Function(ProductImageDto) _then) = _$ProductImageDtoCopyWithImpl;
@useResult
$Res call({
 String url, String? alt, bool isPrimary
});




}
/// @nodoc
class _$ProductImageDtoCopyWithImpl<$Res>
    implements $ProductImageDtoCopyWith<$Res> {
  _$ProductImageDtoCopyWithImpl(this._self, this._then);

  final ProductImageDto _self;
  final $Res Function(ProductImageDto) _then;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? alt = freezed,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductImageDto].
extension ProductImageDtoPatterns on ProductImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductImageDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String? alt,  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
return $default(_that.url,_that.alt,_that.isPrimary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String? alt,  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _ProductImageDto():
return $default(_that.url,_that.alt,_that.isPrimary);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String? alt,  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _ProductImageDto() when $default != null:
return $default(_that.url,_that.alt,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductImageDto implements ProductImageDto {
  const _ProductImageDto({required this.url, this.alt, this.isPrimary = false});
  factory _ProductImageDto.fromJson(Map<String, dynamic> json) => _$ProductImageDtoFromJson(json);

@override final  String url;
@override final  String? alt;
@override@JsonKey() final  bool isPrimary;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductImageDtoCopyWith<_ProductImageDto> get copyWith => __$ProductImageDtoCopyWithImpl<_ProductImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductImageDto&&(identical(other.url, url) || other.url == url)&&(identical(other.alt, alt) || other.alt == alt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,alt,isPrimary);

@override
String toString() {
  return 'ProductImageDto(url: $url, alt: $alt, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$ProductImageDtoCopyWith<$Res> implements $ProductImageDtoCopyWith<$Res> {
  factory _$ProductImageDtoCopyWith(_ProductImageDto value, $Res Function(_ProductImageDto) _then) = __$ProductImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String url, String? alt, bool isPrimary
});




}
/// @nodoc
class __$ProductImageDtoCopyWithImpl<$Res>
    implements _$ProductImageDtoCopyWith<$Res> {
  __$ProductImageDtoCopyWithImpl(this._self, this._then);

  final _ProductImageDto _self;
  final $Res Function(_ProductImageDto) _then;

/// Create a copy of ProductImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? alt = freezed,Object? isPrimary = null,}) {
  return _then(_ProductImageDto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,alt: freezed == alt ? _self.alt : alt // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
