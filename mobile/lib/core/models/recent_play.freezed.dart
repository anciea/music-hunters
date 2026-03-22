// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_play.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentPlay {

 TrackDto get track; int get playedAt;
/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentPlayCopyWith<RecentPlay> get copyWith => _$RecentPlayCopyWithImpl<RecentPlay>(this as RecentPlay, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentPlay&&(identical(other.track, track) || other.track == track)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt));
}


@override
int get hashCode => Object.hash(runtimeType,track,playedAt);

@override
String toString() {
  return 'RecentPlay(track: $track, playedAt: $playedAt)';
}


}

/// @nodoc
abstract mixin class $RecentPlayCopyWith<$Res>  {
  factory $RecentPlayCopyWith(RecentPlay value, $Res Function(RecentPlay) _then) = _$RecentPlayCopyWithImpl;
@useResult
$Res call({
 TrackDto track, int playedAt
});


$TrackDtoCopyWith<$Res> get track;

}
/// @nodoc
class _$RecentPlayCopyWithImpl<$Res>
    implements $RecentPlayCopyWith<$Res> {
  _$RecentPlayCopyWithImpl(this._self, this._then);

  final RecentPlay _self;
  final $Res Function(RecentPlay) _then;

/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? track = null,Object? playedAt = null,}) {
  return _then(_self.copyWith(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as TrackDto,playedAt: null == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackDtoCopyWith<$Res> get track {
  
  return $TrackDtoCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecentPlay].
extension RecentPlayPatterns on RecentPlay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentPlay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentPlay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentPlay value)  $default,){
final _that = this;
switch (_that) {
case _RecentPlay():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentPlay value)?  $default,){
final _that = this;
switch (_that) {
case _RecentPlay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrackDto track,  int playedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentPlay() when $default != null:
return $default(_that.track,_that.playedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrackDto track,  int playedAt)  $default,) {final _that = this;
switch (_that) {
case _RecentPlay():
return $default(_that.track,_that.playedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrackDto track,  int playedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecentPlay() when $default != null:
return $default(_that.track,_that.playedAt);case _:
  return null;

}
}

}

/// @nodoc


class _RecentPlay implements RecentPlay {
  const _RecentPlay({required this.track, required this.playedAt});
  

@override final  TrackDto track;
@override final  int playedAt;

/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentPlayCopyWith<_RecentPlay> get copyWith => __$RecentPlayCopyWithImpl<_RecentPlay>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentPlay&&(identical(other.track, track) || other.track == track)&&(identical(other.playedAt, playedAt) || other.playedAt == playedAt));
}


@override
int get hashCode => Object.hash(runtimeType,track,playedAt);

@override
String toString() {
  return 'RecentPlay(track: $track, playedAt: $playedAt)';
}


}

/// @nodoc
abstract mixin class _$RecentPlayCopyWith<$Res> implements $RecentPlayCopyWith<$Res> {
  factory _$RecentPlayCopyWith(_RecentPlay value, $Res Function(_RecentPlay) _then) = __$RecentPlayCopyWithImpl;
@override @useResult
$Res call({
 TrackDto track, int playedAt
});


@override $TrackDtoCopyWith<$Res> get track;

}
/// @nodoc
class __$RecentPlayCopyWithImpl<$Res>
    implements _$RecentPlayCopyWith<$Res> {
  __$RecentPlayCopyWithImpl(this._self, this._then);

  final _RecentPlay _self;
  final $Res Function(_RecentPlay) _then;

/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? track = null,Object? playedAt = null,}) {
  return _then(_RecentPlay(
track: null == track ? _self.track : track // ignore: cast_nullable_to_non_nullable
as TrackDto,playedAt: null == playedAt ? _self.playedAt : playedAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of RecentPlay
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackDtoCopyWith<$Res> get track {
  
  return $TrackDtoCopyWith<$Res>(_self.track, (value) {
    return _then(_self.copyWith(track: value));
  });
}
}

// dart format on
