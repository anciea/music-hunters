// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadEntry {

 DownloadStatus get status; double get progress; String? get localPath; int get fileSize;
/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadEntryCopyWith<DownloadEntry> get copyWith => _$DownloadEntryCopyWithImpl<DownloadEntry>(this as DownloadEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize));
}


@override
int get hashCode => Object.hash(runtimeType,status,progress,localPath,fileSize);

@override
String toString() {
  return 'DownloadEntry(status: $status, progress: $progress, localPath: $localPath, fileSize: $fileSize)';
}


}

/// @nodoc
abstract mixin class $DownloadEntryCopyWith<$Res>  {
  factory $DownloadEntryCopyWith(DownloadEntry value, $Res Function(DownloadEntry) _then) = _$DownloadEntryCopyWithImpl;
@useResult
$Res call({
 DownloadStatus status, double progress, String? localPath, int fileSize
});




}
/// @nodoc
class _$DownloadEntryCopyWithImpl<$Res>
    implements $DownloadEntryCopyWith<$Res> {
  _$DownloadEntryCopyWithImpl(this._self, this._then);

  final DownloadEntry _self;
  final $Res Function(DownloadEntry) _then;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? progress = null,Object? localPath = freezed,Object? fileSize = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadEntry].
extension DownloadEntryPatterns on DownloadEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadEntry value)  $default,){
final _that = this;
switch (_that) {
case _DownloadEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadEntry value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DownloadStatus status,  double progress,  String? localPath,  int fileSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
return $default(_that.status,_that.progress,_that.localPath,_that.fileSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DownloadStatus status,  double progress,  String? localPath,  int fileSize)  $default,) {final _that = this;
switch (_that) {
case _DownloadEntry():
return $default(_that.status,_that.progress,_that.localPath,_that.fileSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DownloadStatus status,  double progress,  String? localPath,  int fileSize)?  $default,) {final _that = this;
switch (_that) {
case _DownloadEntry() when $default != null:
return $default(_that.status,_that.progress,_that.localPath,_that.fileSize);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadEntry implements DownloadEntry {
  const _DownloadEntry({required this.status, this.progress = 0.0, this.localPath, this.fileSize = 0});
  

@override final  DownloadStatus status;
@override@JsonKey() final  double progress;
@override final  String? localPath;
@override@JsonKey() final  int fileSize;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadEntryCopyWith<_DownloadEntry> get copyWith => __$DownloadEntryCopyWithImpl<_DownloadEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize));
}


@override
int get hashCode => Object.hash(runtimeType,status,progress,localPath,fileSize);

@override
String toString() {
  return 'DownloadEntry(status: $status, progress: $progress, localPath: $localPath, fileSize: $fileSize)';
}


}

/// @nodoc
abstract mixin class _$DownloadEntryCopyWith<$Res> implements $DownloadEntryCopyWith<$Res> {
  factory _$DownloadEntryCopyWith(_DownloadEntry value, $Res Function(_DownloadEntry) _then) = __$DownloadEntryCopyWithImpl;
@override @useResult
$Res call({
 DownloadStatus status, double progress, String? localPath, int fileSize
});




}
/// @nodoc
class __$DownloadEntryCopyWithImpl<$Res>
    implements _$DownloadEntryCopyWith<$Res> {
  __$DownloadEntryCopyWithImpl(this._self, this._then);

  final _DownloadEntry _self;
  final $Res Function(_DownloadEntry) _then;

/// Create a copy of DownloadEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? progress = null,Object? localPath = freezed,Object? fileSize = null,}) {
  return _then(_DownloadEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DownloadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
