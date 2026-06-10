// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductDetailState()';
}


}

/// @nodoc
class $ProductDetailStateCopyWith<$Res>  {
$ProductDetailStateCopyWith(ProductDetailState _, $Res Function(ProductDetailState) __);
}


/// Adds pattern-matching-related methods to [ProductDetailState].
extension ProductDetailStatePatterns on ProductDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProductDetailLoading value)?  loading,TResult Function( ProductDetailReady value)?  ready,TResult Function( ProductDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProductDetailLoading() when loading != null:
return loading(_that);case ProductDetailReady() when ready != null:
return ready(_that);case ProductDetailError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProductDetailLoading value)  loading,required TResult Function( ProductDetailReady value)  ready,required TResult Function( ProductDetailError value)  error,}){
final _that = this;
switch (_that) {
case ProductDetailLoading():
return loading(_that);case ProductDetailReady():
return ready(_that);case ProductDetailError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProductDetailLoading value)?  loading,TResult? Function( ProductDetailReady value)?  ready,TResult? Function( ProductDetailError value)?  error,}){
final _that = this;
switch (_that) {
case ProductDetailLoading() when loading != null:
return loading(_that);case ProductDetailReady() when ready != null:
return ready(_that);case ProductDetailError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Product product,  int qty,  int activeTab,  int activeImage)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProductDetailLoading() when loading != null:
return loading();case ProductDetailReady() when ready != null:
return ready(_that.product,_that.qty,_that.activeTab,_that.activeImage);case ProductDetailError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Product product,  int qty,  int activeTab,  int activeImage)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ProductDetailLoading():
return loading();case ProductDetailReady():
return ready(_that.product,_that.qty,_that.activeTab,_that.activeImage);case ProductDetailError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Product product,  int qty,  int activeTab,  int activeImage)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ProductDetailLoading() when loading != null:
return loading();case ProductDetailReady() when ready != null:
return ready(_that.product,_that.qty,_that.activeTab,_that.activeImage);case ProductDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProductDetailLoading implements ProductDetailState {
  const ProductDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProductDetailState.loading()';
}


}




/// @nodoc


class ProductDetailReady implements ProductDetailState {
  const ProductDetailReady({required this.product, this.qty = 1, this.activeTab = 0, this.activeImage = 0});
  

 final  Product product;
@JsonKey() final  int qty;
@JsonKey() final  int activeTab;
@JsonKey() final  int activeImage;

/// Create a copy of ProductDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailReadyCopyWith<ProductDetailReady> get copyWith => _$ProductDetailReadyCopyWithImpl<ProductDetailReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailReady&&(identical(other.product, product) || other.product == product)&&(identical(other.qty, qty) || other.qty == qty)&&(identical(other.activeTab, activeTab) || other.activeTab == activeTab)&&(identical(other.activeImage, activeImage) || other.activeImage == activeImage));
}


@override
int get hashCode => Object.hash(runtimeType,product,qty,activeTab,activeImage);

@override
String toString() {
  return 'ProductDetailState.ready(product: $product, qty: $qty, activeTab: $activeTab, activeImage: $activeImage)';
}


}

/// @nodoc
abstract mixin class $ProductDetailReadyCopyWith<$Res> implements $ProductDetailStateCopyWith<$Res> {
  factory $ProductDetailReadyCopyWith(ProductDetailReady value, $Res Function(ProductDetailReady) _then) = _$ProductDetailReadyCopyWithImpl;
@useResult
$Res call({
 Product product, int qty, int activeTab, int activeImage
});




}
/// @nodoc
class _$ProductDetailReadyCopyWithImpl<$Res>
    implements $ProductDetailReadyCopyWith<$Res> {
  _$ProductDetailReadyCopyWithImpl(this._self, this._then);

  final ProductDetailReady _self;
  final $Res Function(ProductDetailReady) _then;

/// Create a copy of ProductDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? product = null,Object? qty = null,Object? activeTab = null,Object? activeImage = null,}) {
  return _then(ProductDetailReady(
product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as Product,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as int,activeTab: null == activeTab ? _self.activeTab : activeTab // ignore: cast_nullable_to_non_nullable
as int,activeImage: null == activeImage ? _self.activeImage : activeImage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ProductDetailError implements ProductDetailState {
  const ProductDetailError(this.message);
  

 final  String message;

/// Create a copy of ProductDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductDetailErrorCopyWith<ProductDetailError> get copyWith => _$ProductDetailErrorCopyWithImpl<ProductDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProductDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProductDetailErrorCopyWith<$Res> implements $ProductDetailStateCopyWith<$Res> {
  factory $ProductDetailErrorCopyWith(ProductDetailError value, $Res Function(ProductDetailError) _then) = _$ProductDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProductDetailErrorCopyWithImpl<$Res>
    implements $ProductDetailErrorCopyWith<$Res> {
  _$ProductDetailErrorCopyWithImpl(this._self, this._then);

  final ProductDetailError _self;
  final $Res Function(ProductDetailError) _then;

/// Create a copy of ProductDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProductDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
