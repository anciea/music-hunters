// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaylistModel {

 int get id; String get name; int get createdAt; int get trackCount; List<String?> get coverUrls;
/// Create a copy of PlaylistModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaylistModelCopyWith<PlaylistModel> get copyWith => _$PlaylistModelCopyWithImpl<PlaylistModel>(this as PlaylistModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaylistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&const DeepCollectionEquality().equals(other.coverUrls, coverUrls));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,trackCount,const DeepCollectionEquality().hash(coverUrls));

@override
String toString() {
  return 'PlaylistModel(id: $id, name: $name, createdAt: $createdAt, trackCount: $trackCount, coverUrls: $coverUrls)';
}


}

/// @nodoc
abstract mixin class $PlaylistModelCopyWith<$Res>  {
  factory $PlaylistModelCopyWith(PlaylistModel value, $Res Function(PlaylistModel) _then) = _$PlaylistModelCopyWithImpl;
@useResult
$Res call({
 int id, String name, int createdAt, int trackCount, List<String?> coverUrls
});




}
/// @nodoc
class _$PlaylistModelCopyWithImpl<$Res>
    implements $PlaylistModelCopyWith<$Res> {
  _$PlaylistModelCopyWithImpl(this._self, this._then);

  final PlaylistModel _self;
  final $Res Function(PlaylistModel) _then;

/// Create a copy of PlaylistModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? trackCount = null,Object? coverUrls = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,coverUrls: null == coverUrls ? _self.coverUrls : coverUrls // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaylistModel].
extension PlaylistModelPatterns on PlaylistModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaylistModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaylistModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaylistModel value)  $default,){
final _that = this;
switch (_that) {
case _PlaylistModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaylistModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlaylistModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int createdAt,  int trackCount,  List<String?> coverUrls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaylistModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.trackCount,_that.coverUrls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int createdAt,  int trackCount,  List<String?> coverUrls)  $default,) {final _that = this;
switch (_that) {
case _PlaylistModel():
return $default(_that.id,_that.name,_that.createdAt,_that.trackCount,_that.coverUrls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int createdAt,  int trackCount,  List<String?> coverUrls)?  $default,) {final _that = this;
switch (_that) {
case _PlaylistModel() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.trackCount,_that.coverUrls);case _:
  return null;

}
}

}

/// @nodoc


class _PlaylistModel implements PlaylistModel {
  const _PlaylistModel({required this.id, required this.name, required this.createdAt, this.trackCount = 0, final  List<String?> coverUrls = const []}): _coverUrls = coverUrls;
  

@override final  int id;
@override final  String name;
@override final  int createdAt;
@override@JsonKey() final  int trackCount;
 final  List<String?> _coverUrls;
@override@JsonKey() List<String?> get coverUrls {
  if (_coverUrls is EqualUnmodifiableListView) return _coverUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coverUrls);
}


/// Create a copy of PlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaylistModelCopyWith<_PlaylistModel> get copyWith => __$PlaylistModelCopyWithImpl<_PlaylistModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaylistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.trackCount, trackCount) || other.trackCount == trackCount)&&const DeepCollectionEquality().equals(other._coverUrls, _coverUrls));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,trackCount,const DeepCollectionEquality().hash(_coverUrls));

@override
String toString() {
  return 'PlaylistModel(id: $id, name: $name, createdAt: $createdAt, trackCount: $trackCount, coverUrls: $coverUrls)';
}


}

/// @nodoc
abstract mixin class _$PlaylistModelCopyWith<$Res> implements $PlaylistModelCopyWith<$Res> {
  factory _$PlaylistModelCopyWith(_PlaylistModel value, $Res Function(_PlaylistModel) _then) = __$PlaylistModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int createdAt, int trackCount, List<String?> coverUrls
});




}
/// @nodoc
class __$PlaylistModelCopyWithImpl<$Res>
    implements _$PlaylistModelCopyWith<$Res> {
  __$PlaylistModelCopyWithImpl(this._self, this._then);

  final _PlaylistModel _self;
  final $Res Function(_PlaylistModel) _then;

/// Create a copy of PlaylistModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? trackCount = null,Object? coverUrls = null,}) {
  return _then(_PlaylistModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,trackCount: null == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int,coverUrls: null == coverUrls ? _self._coverUrls : coverUrls // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}


}

// dart format on
