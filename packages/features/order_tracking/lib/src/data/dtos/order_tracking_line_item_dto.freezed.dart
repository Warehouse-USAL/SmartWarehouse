// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_line_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderTrackingLineItemDto {

 String get productId; String? get name; int get quantity;
/// Create a copy of OrderTrackingLineItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingLineItemDtoCopyWith<OrderTrackingLineItemDto> get copyWith => _$OrderTrackingLineItemDtoCopyWithImpl<OrderTrackingLineItemDto>(this as OrderTrackingLineItemDto, _$identity);

  /// Serializes this OrderTrackingLineItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackingLineItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,quantity);

@override
String toString() {
  return 'OrderTrackingLineItemDto(productId: $productId, name: $name, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $OrderTrackingLineItemDtoCopyWith<$Res>  {
  factory $OrderTrackingLineItemDtoCopyWith(OrderTrackingLineItemDto value, $Res Function(OrderTrackingLineItemDto) _then) = _$OrderTrackingLineItemDtoCopyWithImpl;
@useResult
$Res call({
 String productId, String? name, int quantity
});




}
/// @nodoc
class _$OrderTrackingLineItemDtoCopyWithImpl<$Res>
    implements $OrderTrackingLineItemDtoCopyWith<$Res> {
  _$OrderTrackingLineItemDtoCopyWithImpl(this._self, this._then);

  final OrderTrackingLineItemDto _self;
  final $Res Function(OrderTrackingLineItemDto) _then;

/// Create a copy of OrderTrackingLineItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? name = freezed,Object? quantity = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTrackingLineItemDto].
extension OrderTrackingLineItemDtoPatterns on OrderTrackingLineItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTrackingLineItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTrackingLineItemDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTrackingLineItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String? name,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String? name,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto():
return $default(_that.productId,_that.name,_that.quantity);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String? name,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingLineItemDto() when $default != null:
return $default(_that.productId,_that.name,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTrackingLineItemDto implements OrderTrackingLineItemDto {
  const _OrderTrackingLineItemDto({required this.productId, this.name, this.quantity = 0});
  factory _OrderTrackingLineItemDto.fromJson(Map<String, dynamic> json) => _$OrderTrackingLineItemDtoFromJson(json);

@override final  String productId;
@override final  String? name;
@override@JsonKey() final  int quantity;

/// Create a copy of OrderTrackingLineItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingLineItemDtoCopyWith<_OrderTrackingLineItemDto> get copyWith => __$OrderTrackingLineItemDtoCopyWithImpl<_OrderTrackingLineItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTrackingLineItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTrackingLineItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,name,quantity);

@override
String toString() {
  return 'OrderTrackingLineItemDto(productId: $productId, name: $name, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingLineItemDtoCopyWith<$Res> implements $OrderTrackingLineItemDtoCopyWith<$Res> {
  factory _$OrderTrackingLineItemDtoCopyWith(_OrderTrackingLineItemDto value, $Res Function(_OrderTrackingLineItemDto) _then) = __$OrderTrackingLineItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String productId, String? name, int quantity
});




}
/// @nodoc
class __$OrderTrackingLineItemDtoCopyWithImpl<$Res>
    implements _$OrderTrackingLineItemDtoCopyWith<$Res> {
  __$OrderTrackingLineItemDtoCopyWithImpl(this._self, this._then);

  final _OrderTrackingLineItemDto _self;
  final $Res Function(_OrderTrackingLineItemDto) _then;

/// Create a copy of OrderTrackingLineItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? name = freezed,Object? quantity = null,}) {
  return _then(_OrderTrackingLineItemDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
