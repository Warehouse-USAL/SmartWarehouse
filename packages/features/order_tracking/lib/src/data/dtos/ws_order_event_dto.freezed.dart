// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ws_order_event_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WsOrderEventDto {

 String get event; WsOrderPayloadDto get payload;
/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WsOrderEventDtoCopyWith<WsOrderEventDto> get copyWith => _$WsOrderEventDtoCopyWithImpl<WsOrderEventDto>(this as WsOrderEventDto, _$identity);

  /// Serializes this WsOrderEventDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WsOrderEventDto&&(identical(other.event, event) || other.event == event)&&(identical(other.payload, payload) || other.payload == payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,event,payload);

@override
String toString() {
  return 'WsOrderEventDto(event: $event, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $WsOrderEventDtoCopyWith<$Res>  {
  factory $WsOrderEventDtoCopyWith(WsOrderEventDto value, $Res Function(WsOrderEventDto) _then) = _$WsOrderEventDtoCopyWithImpl;
@useResult
$Res call({
 String event, WsOrderPayloadDto payload
});


$WsOrderPayloadDtoCopyWith<$Res> get payload;

}
/// @nodoc
class _$WsOrderEventDtoCopyWithImpl<$Res>
    implements $WsOrderEventDtoCopyWith<$Res> {
  _$WsOrderEventDtoCopyWithImpl(this._self, this._then);

  final WsOrderEventDto _self;
  final $Res Function(WsOrderEventDto) _then;

/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? event = null,Object? payload = null,}) {
  return _then(_self.copyWith(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as WsOrderPayloadDto,
  ));
}
/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WsOrderPayloadDtoCopyWith<$Res> get payload {
  
  return $WsOrderPayloadDtoCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// Adds pattern-matching-related methods to [WsOrderEventDto].
extension WsOrderEventDtoPatterns on WsOrderEventDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WsOrderEventDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WsOrderEventDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WsOrderEventDto value)  $default,){
final _that = this;
switch (_that) {
case _WsOrderEventDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WsOrderEventDto value)?  $default,){
final _that = this;
switch (_that) {
case _WsOrderEventDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String event,  WsOrderPayloadDto payload)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WsOrderEventDto() when $default != null:
return $default(_that.event,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String event,  WsOrderPayloadDto payload)  $default,) {final _that = this;
switch (_that) {
case _WsOrderEventDto():
return $default(_that.event,_that.payload);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String event,  WsOrderPayloadDto payload)?  $default,) {final _that = this;
switch (_that) {
case _WsOrderEventDto() when $default != null:
return $default(_that.event,_that.payload);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WsOrderEventDto implements WsOrderEventDto {
  const _WsOrderEventDto({required this.event, required this.payload});
  factory _WsOrderEventDto.fromJson(Map<String, dynamic> json) => _$WsOrderEventDtoFromJson(json);

@override final  String event;
@override final  WsOrderPayloadDto payload;

/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WsOrderEventDtoCopyWith<_WsOrderEventDto> get copyWith => __$WsOrderEventDtoCopyWithImpl<_WsOrderEventDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WsOrderEventDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WsOrderEventDto&&(identical(other.event, event) || other.event == event)&&(identical(other.payload, payload) || other.payload == payload));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,event,payload);

@override
String toString() {
  return 'WsOrderEventDto(event: $event, payload: $payload)';
}


}

/// @nodoc
abstract mixin class _$WsOrderEventDtoCopyWith<$Res> implements $WsOrderEventDtoCopyWith<$Res> {
  factory _$WsOrderEventDtoCopyWith(_WsOrderEventDto value, $Res Function(_WsOrderEventDto) _then) = __$WsOrderEventDtoCopyWithImpl;
@override @useResult
$Res call({
 String event, WsOrderPayloadDto payload
});


@override $WsOrderPayloadDtoCopyWith<$Res> get payload;

}
/// @nodoc
class __$WsOrderEventDtoCopyWithImpl<$Res>
    implements _$WsOrderEventDtoCopyWith<$Res> {
  __$WsOrderEventDtoCopyWithImpl(this._self, this._then);

  final _WsOrderEventDto _self;
  final $Res Function(_WsOrderEventDto) _then;

/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? event = null,Object? payload = null,}) {
  return _then(_WsOrderEventDto(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as WsOrderPayloadDto,
  ));
}

/// Create a copy of WsOrderEventDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WsOrderPayloadDtoCopyWith<$Res> get payload {
  
  return $WsOrderPayloadDtoCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}

// dart format on
