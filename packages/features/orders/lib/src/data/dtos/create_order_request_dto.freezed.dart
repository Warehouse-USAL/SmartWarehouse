// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_order_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateOrderRequestDto {

 List<CreateOrderItemDto> get items; String get destinationArea; AddressDto get address;
/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderRequestDtoCopyWith<CreateOrderRequestDto> get copyWith => _$CreateOrderRequestDtoCopyWithImpl<CreateOrderRequestDto>(this as CreateOrderRequestDto, _$identity);

  /// Serializes this CreateOrderRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderRequestDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.destinationArea, destinationArea) || other.destinationArea == destinationArea)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),destinationArea,address);

@override
String toString() {
  return 'CreateOrderRequestDto(items: $items, destinationArea: $destinationArea, address: $address)';
}


}

/// @nodoc
abstract mixin class $CreateOrderRequestDtoCopyWith<$Res>  {
  factory $CreateOrderRequestDtoCopyWith(CreateOrderRequestDto value, $Res Function(CreateOrderRequestDto) _then) = _$CreateOrderRequestDtoCopyWithImpl;
@useResult
$Res call({
 List<CreateOrderItemDto> items, String destinationArea, AddressDto address
});


$AddressDtoCopyWith<$Res> get address;

}
/// @nodoc
class _$CreateOrderRequestDtoCopyWithImpl<$Res>
    implements $CreateOrderRequestDtoCopyWith<$Res> {
  _$CreateOrderRequestDtoCopyWithImpl(this._self, this._then);

  final CreateOrderRequestDto _self;
  final $Res Function(CreateOrderRequestDto) _then;

/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? destinationArea = null,Object? address = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CreateOrderItemDto>,destinationArea: null == destinationArea ? _self.destinationArea : destinationArea // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressDto,
  ));
}
/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressDtoCopyWith<$Res> get address {
  
  return $AddressDtoCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreateOrderRequestDto].
extension CreateOrderRequestDtoPatterns on CreateOrderRequestDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOrderRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOrderRequestDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOrderRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateOrderRequestDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOrderRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOrderRequestDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CreateOrderItemDto> items,  String destinationArea,  AddressDto address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOrderRequestDto() when $default != null:
return $default(_that.items,_that.destinationArea,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CreateOrderItemDto> items,  String destinationArea,  AddressDto address)  $default,) {final _that = this;
switch (_that) {
case _CreateOrderRequestDto():
return $default(_that.items,_that.destinationArea,_that.address);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CreateOrderItemDto> items,  String destinationArea,  AddressDto address)?  $default,) {final _that = this;
switch (_that) {
case _CreateOrderRequestDto() when $default != null:
return $default(_that.items,_that.destinationArea,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOrderRequestDto implements CreateOrderRequestDto {
  const _CreateOrderRequestDto({required final  List<CreateOrderItemDto> items, required this.destinationArea, required this.address}): _items = items;
  factory _CreateOrderRequestDto.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestDtoFromJson(json);

 final  List<CreateOrderItemDto> _items;
@override List<CreateOrderItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String destinationArea;
@override final  AddressDto address;

/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderRequestDtoCopyWith<_CreateOrderRequestDto> get copyWith => __$CreateOrderRequestDtoCopyWithImpl<_CreateOrderRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderRequestDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.destinationArea, destinationArea) || other.destinationArea == destinationArea)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),destinationArea,address);

@override
String toString() {
  return 'CreateOrderRequestDto(items: $items, destinationArea: $destinationArea, address: $address)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderRequestDtoCopyWith<$Res> implements $CreateOrderRequestDtoCopyWith<$Res> {
  factory _$CreateOrderRequestDtoCopyWith(_CreateOrderRequestDto value, $Res Function(_CreateOrderRequestDto) _then) = __$CreateOrderRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<CreateOrderItemDto> items, String destinationArea, AddressDto address
});


@override $AddressDtoCopyWith<$Res> get address;

}
/// @nodoc
class __$CreateOrderRequestDtoCopyWithImpl<$Res>
    implements _$CreateOrderRequestDtoCopyWith<$Res> {
  __$CreateOrderRequestDtoCopyWithImpl(this._self, this._then);

  final _CreateOrderRequestDto _self;
  final $Res Function(_CreateOrderRequestDto) _then;

/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? destinationArea = null,Object? address = null,}) {
  return _then(_CreateOrderRequestDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CreateOrderItemDto>,destinationArea: null == destinationArea ? _self.destinationArea : destinationArea // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as AddressDto,
  ));
}

/// Create a copy of CreateOrderRequestDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AddressDtoCopyWith<$Res> get address {
  
  return $AddressDtoCopyWith<$Res>(_self.address, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$CreateOrderItemDto {

 String get productId; int get quantity;
/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOrderItemDtoCopyWith<CreateOrderItemDto> get copyWith => _$CreateOrderItemDtoCopyWithImpl<CreateOrderItemDto>(this as CreateOrderItemDto, _$identity);

  /// Serializes this CreateOrderItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOrderItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity);

@override
String toString() {
  return 'CreateOrderItemDto(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $CreateOrderItemDtoCopyWith<$Res>  {
  factory $CreateOrderItemDtoCopyWith(CreateOrderItemDto value, $Res Function(CreateOrderItemDto) _then) = _$CreateOrderItemDtoCopyWithImpl;
@useResult
$Res call({
 String productId, int quantity
});




}
/// @nodoc
class _$CreateOrderItemDtoCopyWithImpl<$Res>
    implements $CreateOrderItemDtoCopyWith<$Res> {
  _$CreateOrderItemDtoCopyWithImpl(this._self, this._then);

  final CreateOrderItemDto _self;
  final $Res Function(CreateOrderItemDto) _then;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateOrderItemDto].
extension CreateOrderItemDtoPatterns on CreateOrderItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateOrderItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateOrderItemDto value)  $default,){
final _that = this;
switch (_that) {
case _CreateOrderItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateOrderItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that.productId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _CreateOrderItemDto():
return $default(_that.productId,_that.quantity);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _CreateOrderItemDto() when $default != null:
return $default(_that.productId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateOrderItemDto implements CreateOrderItemDto {
  const _CreateOrderItemDto({required this.productId, required this.quantity});
  factory _CreateOrderItemDto.fromJson(Map<String, dynamic> json) => _$CreateOrderItemDtoFromJson(json);

@override final  String productId;
@override final  int quantity;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateOrderItemDtoCopyWith<_CreateOrderItemDto> get copyWith => __$CreateOrderItemDtoCopyWithImpl<_CreateOrderItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateOrderItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateOrderItemDto&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity);

@override
String toString() {
  return 'CreateOrderItemDto(productId: $productId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$CreateOrderItemDtoCopyWith<$Res> implements $CreateOrderItemDtoCopyWith<$Res> {
  factory _$CreateOrderItemDtoCopyWith(_CreateOrderItemDto value, $Res Function(_CreateOrderItemDto) _then) = __$CreateOrderItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String productId, int quantity
});




}
/// @nodoc
class __$CreateOrderItemDtoCopyWithImpl<$Res>
    implements _$CreateOrderItemDtoCopyWith<$Res> {
  __$CreateOrderItemDtoCopyWithImpl(this._self, this._then);

  final _CreateOrderItemDto _self;
  final $Res Function(_CreateOrderItemDto) _then;

/// Create a copy of CreateOrderItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,}) {
  return _then(_CreateOrderItemDto(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AddressDto {

 String get street; String get postalCode; String? get department; String? get floor;
/// Create a copy of AddressDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressDtoCopyWith<AddressDto> get copyWith => _$AddressDtoCopyWithImpl<AddressDto>(this as AddressDto, _$identity);

  /// Serializes this AddressDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressDto&&(identical(other.street, street) || other.street == street)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.department, department) || other.department == department)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,postalCode,department,floor);

@override
String toString() {
  return 'AddressDto(street: $street, postalCode: $postalCode, department: $department, floor: $floor)';
}


}

/// @nodoc
abstract mixin class $AddressDtoCopyWith<$Res>  {
  factory $AddressDtoCopyWith(AddressDto value, $Res Function(AddressDto) _then) = _$AddressDtoCopyWithImpl;
@useResult
$Res call({
 String street, String postalCode, String? department, String? floor
});




}
/// @nodoc
class _$AddressDtoCopyWithImpl<$Res>
    implements $AddressDtoCopyWith<$Res> {
  _$AddressDtoCopyWithImpl(this._self, this._then);

  final AddressDto _self;
  final $Res Function(AddressDto) _then;

/// Create a copy of AddressDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = null,Object? postalCode = null,Object? department = freezed,Object? floor = freezed,}) {
  return _then(_self.copyWith(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressDto].
extension AddressDtoPatterns on AddressDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressDto value)  $default,){
final _that = this;
switch (_that) {
case _AddressDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressDto value)?  $default,){
final _that = this;
switch (_that) {
case _AddressDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String street,  String postalCode,  String? department,  String? floor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressDto() when $default != null:
return $default(_that.street,_that.postalCode,_that.department,_that.floor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String street,  String postalCode,  String? department,  String? floor)  $default,) {final _that = this;
switch (_that) {
case _AddressDto():
return $default(_that.street,_that.postalCode,_that.department,_that.floor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String street,  String postalCode,  String? department,  String? floor)?  $default,) {final _that = this;
switch (_that) {
case _AddressDto() when $default != null:
return $default(_that.street,_that.postalCode,_that.department,_that.floor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddressDto implements AddressDto {
  const _AddressDto({required this.street, required this.postalCode, this.department, this.floor});
  factory _AddressDto.fromJson(Map<String, dynamic> json) => _$AddressDtoFromJson(json);

@override final  String street;
@override final  String postalCode;
@override final  String? department;
@override final  String? floor;

/// Create a copy of AddressDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressDtoCopyWith<_AddressDto> get copyWith => __$AddressDtoCopyWithImpl<_AddressDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddressDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressDto&&(identical(other.street, street) || other.street == street)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.department, department) || other.department == department)&&(identical(other.floor, floor) || other.floor == floor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,postalCode,department,floor);

@override
String toString() {
  return 'AddressDto(street: $street, postalCode: $postalCode, department: $department, floor: $floor)';
}


}

/// @nodoc
abstract mixin class _$AddressDtoCopyWith<$Res> implements $AddressDtoCopyWith<$Res> {
  factory _$AddressDtoCopyWith(_AddressDto value, $Res Function(_AddressDto) _then) = __$AddressDtoCopyWithImpl;
@override @useResult
$Res call({
 String street, String postalCode, String? department, String? floor
});




}
/// @nodoc
class __$AddressDtoCopyWithImpl<$Res>
    implements _$AddressDtoCopyWith<$Res> {
  __$AddressDtoCopyWithImpl(this._self, this._then);

  final _AddressDto _self;
  final $Res Function(_AddressDto) _then;

/// Create a copy of AddressDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = null,Object? postalCode = null,Object? department = freezed,Object? floor = freezed,}) {
  return _then(_AddressDto(
street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
