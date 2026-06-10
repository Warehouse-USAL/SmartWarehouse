// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderTrackingItemDto {

 String get id; String get status; List<OrderTrackingLineItemDto> get items; String? get createdAt;
/// Create a copy of OrderTrackingItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingItemDtoCopyWith<OrderTrackingItemDto> get copyWith => _$OrderTrackingItemDtoCopyWithImpl<OrderTrackingItemDto>(this as OrderTrackingItemDto, _$identity);

  /// Serializes this OrderTrackingItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTrackingItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,const DeepCollectionEquality().hash(items),createdAt);

@override
String toString() {
  return 'OrderTrackingItemDto(id: $id, status: $status, items: $items, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderTrackingItemDtoCopyWith<$Res>  {
  factory $OrderTrackingItemDtoCopyWith(OrderTrackingItemDto value, $Res Function(OrderTrackingItemDto) _then) = _$OrderTrackingItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String status, List<OrderTrackingLineItemDto> items, String? createdAt
});




}
/// @nodoc
class _$OrderTrackingItemDtoCopyWithImpl<$Res>
    implements $OrderTrackingItemDtoCopyWith<$Res> {
  _$OrderTrackingItemDtoCopyWithImpl(this._self, this._then);

  final OrderTrackingItemDto _self;
  final $Res Function(OrderTrackingItemDto) _then;

/// Create a copy of OrderTrackingItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? items = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderTrackingLineItemDto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderTrackingItemDto].
extension OrderTrackingItemDtoPatterns on OrderTrackingItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTrackingItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTrackingItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTrackingItemDto value)  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTrackingItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTrackingItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  List<OrderTrackingLineItemDto> items,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTrackingItemDto() when $default != null:
return $default(_that.id,_that.status,_that.items,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  List<OrderTrackingLineItemDto> items,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingItemDto():
return $default(_that.id,_that.status,_that.items,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  List<OrderTrackingLineItemDto> items,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderTrackingItemDto() when $default != null:
return $default(_that.id,_that.status,_that.items,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderTrackingItemDto implements OrderTrackingItemDto {
  const _OrderTrackingItemDto({required this.id, required this.status, final  List<OrderTrackingLineItemDto> items = const [], this.createdAt}): _items = items;
  factory _OrderTrackingItemDto.fromJson(Map<String, dynamic> json) => _$OrderTrackingItemDtoFromJson(json);

@override final  String id;
@override final  String status;
 final  List<OrderTrackingLineItemDto> _items;
@override@JsonKey() List<OrderTrackingLineItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? createdAt;

/// Create a copy of OrderTrackingItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingItemDtoCopyWith<_OrderTrackingItemDto> get copyWith => __$OrderTrackingItemDtoCopyWithImpl<_OrderTrackingItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderTrackingItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTrackingItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,const DeepCollectionEquality().hash(_items),createdAt);

@override
String toString() {
  return 'OrderTrackingItemDto(id: $id, status: $status, items: $items, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingItemDtoCopyWith<$Res> implements $OrderTrackingItemDtoCopyWith<$Res> {
  factory _$OrderTrackingItemDtoCopyWith(_OrderTrackingItemDto value, $Res Function(_OrderTrackingItemDto) _then) = __$OrderTrackingItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, List<OrderTrackingLineItemDto> items, String? createdAt
});




}
/// @nodoc
class __$OrderTrackingItemDtoCopyWithImpl<$Res>
    implements _$OrderTrackingItemDtoCopyWith<$Res> {
  __$OrderTrackingItemDtoCopyWithImpl(this._self, this._then);

  final _OrderTrackingItemDto _self;
  final $Res Function(_OrderTrackingItemDto) _then;

/// Create a copy of OrderTrackingItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? items = null,Object? createdAt = freezed,}) {
  return _then(_OrderTrackingItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderTrackingLineItemDto>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
