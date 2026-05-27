// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_bar_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationBarOption {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationBarOption);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationBarOption()';
}


}

/// @nodoc
class $NavigationBarOptionCopyWith<$Res>  {
$NavigationBarOptionCopyWith(NavigationBarOption _, $Res Function(NavigationBarOption) __);
}


/// Adds pattern-matching-related methods to [NavigationBarOption].
extension NavigationBarOptionPatterns on NavigationBarOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileNavigationBarOption value)?  profile,TResult Function( ProductsNavigationBarOption value)?  products,TResult Function( CartNavigationBarOption value)?  cart,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileNavigationBarOption() when profile != null:
return profile(_that);case ProductsNavigationBarOption() when products != null:
return products(_that);case CartNavigationBarOption() when cart != null:
return cart(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileNavigationBarOption value)  profile,required TResult Function( ProductsNavigationBarOption value)  products,required TResult Function( CartNavigationBarOption value)  cart,}){
final _that = this;
switch (_that) {
case ProfileNavigationBarOption():
return profile(_that);case ProductsNavigationBarOption():
return products(_that);case CartNavigationBarOption():
return cart(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileNavigationBarOption value)?  profile,TResult? Function( ProductsNavigationBarOption value)?  products,TResult? Function( CartNavigationBarOption value)?  cart,}){
final _that = this;
switch (_that) {
case ProfileNavigationBarOption() when profile != null:
return profile(_that);case ProductsNavigationBarOption() when products != null:
return products(_that);case CartNavigationBarOption() when cart != null:
return cart(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  profile,TResult Function()?  products,TResult Function()?  cart,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileNavigationBarOption() when profile != null:
return profile();case ProductsNavigationBarOption() when products != null:
return products();case CartNavigationBarOption() when cart != null:
return cart();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  profile,required TResult Function()  products,required TResult Function()  cart,}) {final _that = this;
switch (_that) {
case ProfileNavigationBarOption():
return profile();case ProductsNavigationBarOption():
return products();case CartNavigationBarOption():
return cart();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  profile,TResult? Function()?  products,TResult? Function()?  cart,}) {final _that = this;
switch (_that) {
case ProfileNavigationBarOption() when profile != null:
return profile();case ProductsNavigationBarOption() when products != null:
return products();case CartNavigationBarOption() when cart != null:
return cart();case _:
  return null;

}
}

}

/// @nodoc


class ProfileNavigationBarOption extends NavigationBarOption {
  const ProfileNavigationBarOption(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileNavigationBarOption);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationBarOption.profile()';
}


}




/// @nodoc


class ProductsNavigationBarOption extends NavigationBarOption {
  const ProductsNavigationBarOption(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsNavigationBarOption);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationBarOption.products()';
}


}




/// @nodoc


class CartNavigationBarOption extends NavigationBarOption {
  const CartNavigationBarOption(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartNavigationBarOption);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationBarOption.cart()';
}


}




// dart format on
