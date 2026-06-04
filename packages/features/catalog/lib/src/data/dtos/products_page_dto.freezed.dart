// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_page_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductsPageDto {

 List<ProductDto> get products; PaginationDto? get pagination;
/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsPageDtoCopyWith<ProductsPageDto> get copyWith => _$ProductsPageDtoCopyWithImpl<ProductsPageDto>(this as ProductsPageDto, _$identity);

  /// Serializes this ProductsPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsPageDto&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(products),pagination);

@override
String toString() {
  return 'ProductsPageDto(products: $products, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class $ProductsPageDtoCopyWith<$Res>  {
  factory $ProductsPageDtoCopyWith(ProductsPageDto value, $Res Function(ProductsPageDto) _then) = _$ProductsPageDtoCopyWithImpl;
@useResult
$Res call({
 List<ProductDto> products, PaginationDto? pagination
});


$PaginationDtoCopyWith<$Res>? get pagination;

}
/// @nodoc
class _$ProductsPageDtoCopyWithImpl<$Res>
    implements $ProductsPageDtoCopyWith<$Res> {
  _$ProductsPageDtoCopyWithImpl(this._self, this._then);

  final ProductsPageDto _self;
  final $Res Function(ProductsPageDto) _then;

/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? products = null,Object? pagination = freezed,}) {
  return _then(_self.copyWith(
products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ProductDto>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,
  ));
}
/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationDtoCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $PaginationDtoCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProductsPageDto].
extension ProductsPageDtoPatterns on ProductsPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsPageDto value)  $default,){
final _that = this;
switch (_that) {
case _ProductsPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProductDto> products,  PaginationDto? pagination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsPageDto() when $default != null:
return $default(_that.products,_that.pagination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProductDto> products,  PaginationDto? pagination)  $default,) {final _that = this;
switch (_that) {
case _ProductsPageDto():
return $default(_that.products,_that.pagination);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProductDto> products,  PaginationDto? pagination)?  $default,) {final _that = this;
switch (_that) {
case _ProductsPageDto() when $default != null:
return $default(_that.products,_that.pagination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductsPageDto implements ProductsPageDto {
  const _ProductsPageDto({final  List<ProductDto> products = const [], this.pagination}): _products = products;
  factory _ProductsPageDto.fromJson(Map<String, dynamic> json) => _$ProductsPageDtoFromJson(json);

 final  List<ProductDto> _products;
@override@JsonKey() List<ProductDto> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override final  PaginationDto? pagination;

/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsPageDtoCopyWith<_ProductsPageDto> get copyWith => __$ProductsPageDtoCopyWithImpl<_ProductsPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductsPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsPageDto&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.pagination, pagination) || other.pagination == pagination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),pagination);

@override
String toString() {
  return 'ProductsPageDto(products: $products, pagination: $pagination)';
}


}

/// @nodoc
abstract mixin class _$ProductsPageDtoCopyWith<$Res> implements $ProductsPageDtoCopyWith<$Res> {
  factory _$ProductsPageDtoCopyWith(_ProductsPageDto value, $Res Function(_ProductsPageDto) _then) = __$ProductsPageDtoCopyWithImpl;
@override @useResult
$Res call({
 List<ProductDto> products, PaginationDto? pagination
});


@override $PaginationDtoCopyWith<$Res>? get pagination;

}
/// @nodoc
class __$ProductsPageDtoCopyWithImpl<$Res>
    implements _$ProductsPageDtoCopyWith<$Res> {
  __$ProductsPageDtoCopyWithImpl(this._self, this._then);

  final _ProductsPageDto _self;
  final $Res Function(_ProductsPageDto) _then;

/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? products = null,Object? pagination = freezed,}) {
  return _then(_ProductsPageDto(
products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ProductDto>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,
  ));
}

/// Create a copy of ProductsPageDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationDtoCopyWith<$Res>? get pagination {
    if (_self.pagination == null) {
    return null;
  }

  return $PaginationDtoCopyWith<$Res>(_self.pagination!, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}

// dart format on
