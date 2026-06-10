// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceDto {

 int get amountCents; String get currency; bool? get taxIncluded;
/// Create a copy of PriceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceDtoCopyWith<PriceDto> get copyWith => _$PriceDtoCopyWithImpl<PriceDto>(this as PriceDto, _$identity);

  /// Serializes this PriceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceDto&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amountCents,currency,taxIncluded);

@override
String toString() {
  return 'PriceDto(amountCents: $amountCents, currency: $currency, taxIncluded: $taxIncluded)';
}


}

/// @nodoc
abstract mixin class $PriceDtoCopyWith<$Res>  {
  factory $PriceDtoCopyWith(PriceDto value, $Res Function(PriceDto) _then) = _$PriceDtoCopyWithImpl;
@useResult
$Res call({
 int amountCents, String currency, bool? taxIncluded
});




}
/// @nodoc
class _$PriceDtoCopyWithImpl<$Res>
    implements $PriceDtoCopyWith<$Res> {
  _$PriceDtoCopyWithImpl(this._self, this._then);

  final PriceDto _self;
  final $Res Function(PriceDto) _then;

/// Create a copy of PriceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amountCents = null,Object? currency = null,Object? taxIncluded = freezed,}) {
  return _then(_self.copyWith(
amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: freezed == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceDto].
extension PriceDtoPatterns on PriceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceDto value)  $default,){
final _that = this;
switch (_that) {
case _PriceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceDto value)?  $default,){
final _that = this;
switch (_that) {
case _PriceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amountCents,  String currency,  bool? taxIncluded)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceDto() when $default != null:
return $default(_that.amountCents,_that.currency,_that.taxIncluded);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amountCents,  String currency,  bool? taxIncluded)  $default,) {final _that = this;
switch (_that) {
case _PriceDto():
return $default(_that.amountCents,_that.currency,_that.taxIncluded);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amountCents,  String currency,  bool? taxIncluded)?  $default,) {final _that = this;
switch (_that) {
case _PriceDto() when $default != null:
return $default(_that.amountCents,_that.currency,_that.taxIncluded);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceDto implements PriceDto {
  const _PriceDto({this.amountCents = 0, this.currency = 'ARS', this.taxIncluded});
  factory _PriceDto.fromJson(Map<String, dynamic> json) => _$PriceDtoFromJson(json);

@override@JsonKey() final  int amountCents;
@override@JsonKey() final  String currency;
@override final  bool? taxIncluded;

/// Create a copy of PriceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceDtoCopyWith<_PriceDto> get copyWith => __$PriceDtoCopyWithImpl<_PriceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceDto&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.taxIncluded, taxIncluded) || other.taxIncluded == taxIncluded));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amountCents,currency,taxIncluded);

@override
String toString() {
  return 'PriceDto(amountCents: $amountCents, currency: $currency, taxIncluded: $taxIncluded)';
}


}

/// @nodoc
abstract mixin class _$PriceDtoCopyWith<$Res> implements $PriceDtoCopyWith<$Res> {
  factory _$PriceDtoCopyWith(_PriceDto value, $Res Function(_PriceDto) _then) = __$PriceDtoCopyWithImpl;
@override @useResult
$Res call({
 int amountCents, String currency, bool? taxIncluded
});




}
/// @nodoc
class __$PriceDtoCopyWithImpl<$Res>
    implements _$PriceDtoCopyWith<$Res> {
  __$PriceDtoCopyWithImpl(this._self, this._then);

  final _PriceDto _self;
  final $Res Function(_PriceDto) _then;

/// Create a copy of PriceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amountCents = null,Object? currency = null,Object? taxIncluded = freezed,}) {
  return _then(_PriceDto(
amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,taxIncluded: freezed == taxIncluded ? _self.taxIncluded : taxIncluded // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
