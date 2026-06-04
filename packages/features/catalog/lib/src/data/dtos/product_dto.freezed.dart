// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductDto {

 String get id; String get sku; String get name; String? get description; String get category; String? get imageUrl; List<ProductImageDto> get images; PriceDto? get price; List<SpecDto> get specs; StockDto? get stock; OrderConstraintsDto? get orderConstraints; ProductLocationDto? get location; String? get createdAt;
/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDtoCopyWith<ProductDto> get copyWith => _$ProductDtoCopyWithImpl<ProductDto>(this as ProductDto, _$identity);

  /// Serializes this ProductDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.specs, specs)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.orderConstraints, orderConstraints) || other.orderConstraints == orderConstraints)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sku,name,description,category,imageUrl,const DeepCollectionEquality().hash(images),price,const DeepCollectionEquality().hash(specs),stock,orderConstraints,location,createdAt);

@override
String toString() {
  return 'ProductDto(id: $id, sku: $sku, name: $name, description: $description, category: $category, imageUrl: $imageUrl, images: $images, price: $price, specs: $specs, stock: $stock, orderConstraints: $orderConstraints, location: $location, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductDtoCopyWith<$Res>  {
  factory $ProductDtoCopyWith(ProductDto value, $Res Function(ProductDto) _then) = _$ProductDtoCopyWithImpl;
@useResult
$Res call({
 String id, String sku, String name, String? description, String category, String? imageUrl, List<ProductImageDto> images, PriceDto? price, List<SpecDto> specs, StockDto? stock, OrderConstraintsDto? orderConstraints, ProductLocationDto? location, String? createdAt
});


$PriceDtoCopyWith<$Res>? get price;$StockDtoCopyWith<$Res>? get stock;$OrderConstraintsDtoCopyWith<$Res>? get orderConstraints;$ProductLocationDtoCopyWith<$Res>? get location;

}
/// @nodoc
class _$ProductDtoCopyWithImpl<$Res>
    implements $ProductDtoCopyWith<$Res> {
  _$ProductDtoCopyWithImpl(this._self, this._then);

  final ProductDto _self;
  final $Res Function(ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? description = freezed,Object? category = null,Object? imageUrl = freezed,Object? images = null,Object? price = freezed,Object? specs = null,Object? stock = freezed,Object? orderConstraints = freezed,Object? location = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImageDto>,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceDto?,specs: null == specs ? _self.specs : specs // ignore: cast_nullable_to_non_nullable
as List<SpecDto>,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as StockDto?,orderConstraints: freezed == orderConstraints ? _self.orderConstraints : orderConstraints // ignore: cast_nullable_to_non_nullable
as OrderConstraintsDto?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ProductLocationDto?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceDtoCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceDtoCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StockDtoCopyWith<$Res>? get stock {
    if (_self.stock == null) {
    return null;
  }

  return $StockDtoCopyWith<$Res>(_self.stock!, (value) {
    return _then(_self.copyWith(stock: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderConstraintsDtoCopyWith<$Res>? get orderConstraints {
    if (_self.orderConstraints == null) {
    return null;
  }

  return $OrderConstraintsDtoCopyWith<$Res>(_self.orderConstraints!, (value) {
    return _then(_self.copyWith(orderConstraints: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductLocationDtoCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $ProductLocationDtoCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductDto].
extension ProductDtoPatterns on ProductDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sku,  String name,  String? description,  String category,  String? imageUrl,  List<ProductImageDto> images,  PriceDto? price,  List<SpecDto> specs,  StockDto? stock,  OrderConstraintsDto? orderConstraints,  ProductLocationDto? location,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.description,_that.category,_that.imageUrl,_that.images,_that.price,_that.specs,_that.stock,_that.orderConstraints,_that.location,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sku,  String name,  String? description,  String category,  String? imageUrl,  List<ProductImageDto> images,  PriceDto? price,  List<SpecDto> specs,  StockDto? stock,  OrderConstraintsDto? orderConstraints,  ProductLocationDto? location,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProductDto():
return $default(_that.id,_that.sku,_that.name,_that.description,_that.category,_that.imageUrl,_that.images,_that.price,_that.specs,_that.stock,_that.orderConstraints,_that.location,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sku,  String name,  String? description,  String category,  String? imageUrl,  List<ProductImageDto> images,  PriceDto? price,  List<SpecDto> specs,  StockDto? stock,  OrderConstraintsDto? orderConstraints,  ProductLocationDto? location,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductDto() when $default != null:
return $default(_that.id,_that.sku,_that.name,_that.description,_that.category,_that.imageUrl,_that.images,_that.price,_that.specs,_that.stock,_that.orderConstraints,_that.location,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductDto implements ProductDto {
  const _ProductDto({required this.id, required this.sku, required this.name, this.description, this.category = 'other', this.imageUrl, final  List<ProductImageDto> images = const [], this.price, final  List<SpecDto> specs = const [], this.stock, this.orderConstraints, this.location, this.createdAt}): _images = images,_specs = specs;
  factory _ProductDto.fromJson(Map<String, dynamic> json) => _$ProductDtoFromJson(json);

@override final  String id;
@override final  String sku;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  String category;
@override final  String? imageUrl;
 final  List<ProductImageDto> _images;
@override@JsonKey() List<ProductImageDto> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  PriceDto? price;
 final  List<SpecDto> _specs;
@override@JsonKey() List<SpecDto> get specs {
  if (_specs is EqualUnmodifiableListView) return _specs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specs);
}

@override final  StockDto? stock;
@override final  OrderConstraintsDto? orderConstraints;
@override final  ProductLocationDto? location;
@override final  String? createdAt;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductDtoCopyWith<_ProductDto> get copyWith => __$ProductDtoCopyWithImpl<_ProductDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductDto&&(identical(other.id, id) || other.id == id)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._specs, _specs)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.orderConstraints, orderConstraints) || other.orderConstraints == orderConstraints)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sku,name,description,category,imageUrl,const DeepCollectionEquality().hash(_images),price,const DeepCollectionEquality().hash(_specs),stock,orderConstraints,location,createdAt);

@override
String toString() {
  return 'ProductDto(id: $id, sku: $sku, name: $name, description: $description, category: $category, imageUrl: $imageUrl, images: $images, price: $price, specs: $specs, stock: $stock, orderConstraints: $orderConstraints, location: $location, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductDtoCopyWith<$Res> implements $ProductDtoCopyWith<$Res> {
  factory _$ProductDtoCopyWith(_ProductDto value, $Res Function(_ProductDto) _then) = __$ProductDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String sku, String name, String? description, String category, String? imageUrl, List<ProductImageDto> images, PriceDto? price, List<SpecDto> specs, StockDto? stock, OrderConstraintsDto? orderConstraints, ProductLocationDto? location, String? createdAt
});


@override $PriceDtoCopyWith<$Res>? get price;@override $StockDtoCopyWith<$Res>? get stock;@override $OrderConstraintsDtoCopyWith<$Res>? get orderConstraints;@override $ProductLocationDtoCopyWith<$Res>? get location;

}
/// @nodoc
class __$ProductDtoCopyWithImpl<$Res>
    implements _$ProductDtoCopyWith<$Res> {
  __$ProductDtoCopyWithImpl(this._self, this._then);

  final _ProductDto _self;
  final $Res Function(_ProductDto) _then;

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sku = null,Object? name = null,Object? description = freezed,Object? category = null,Object? imageUrl = freezed,Object? images = null,Object? price = freezed,Object? specs = null,Object? stock = freezed,Object? orderConstraints = freezed,Object? location = freezed,Object? createdAt = freezed,}) {
  return _then(_ProductDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sku: null == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ProductImageDto>,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as PriceDto?,specs: null == specs ? _self._specs : specs // ignore: cast_nullable_to_non_nullable
as List<SpecDto>,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as StockDto?,orderConstraints: freezed == orderConstraints ? _self.orderConstraints : orderConstraints // ignore: cast_nullable_to_non_nullable
as OrderConstraintsDto?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ProductLocationDto?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PriceDtoCopyWith<$Res>? get price {
    if (_self.price == null) {
    return null;
  }

  return $PriceDtoCopyWith<$Res>(_self.price!, (value) {
    return _then(_self.copyWith(price: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StockDtoCopyWith<$Res>? get stock {
    if (_self.stock == null) {
    return null;
  }

  return $StockDtoCopyWith<$Res>(_self.stock!, (value) {
    return _then(_self.copyWith(stock: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderConstraintsDtoCopyWith<$Res>? get orderConstraints {
    if (_self.orderConstraints == null) {
    return null;
  }

  return $OrderConstraintsDtoCopyWith<$Res>(_self.orderConstraints!, (value) {
    return _then(_self.copyWith(orderConstraints: value));
  });
}/// Create a copy of ProductDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProductLocationDtoCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $ProductLocationDtoCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
