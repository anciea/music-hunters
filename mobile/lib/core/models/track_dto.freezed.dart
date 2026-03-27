// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackDto {

@JsonKey(name: 'track_id') String get trackId;@JsonKey(name: 'song_name') String? get songName; String? get singers; String? get album;@JsonKey(name: 'cover_url') String? get coverUrl;@JsonKey(name: 'duration_s') int? get durationS; String? get duration; String? get source; String? get ext; int? get bitrate; String? get codec;@JsonKey(name: 'file_size') String? get fileSize;@JsonKey(name: 'file_size_bytes') int? get fileSizeBytes;
/// Create a copy of TrackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackDtoCopyWith<TrackDto> get copyWith => _$TrackDtoCopyWithImpl<TrackDto>(this as TrackDto, _$identity);

  /// Serializes this TrackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackDto&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.songName, songName) || other.songName == songName)&&(identical(other.singers, singers) || other.singers == singers)&&(identical(other.album, album) || other.album == album)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationS, durationS) || other.durationS == durationS)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.source, source) || other.source == source)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,songName,singers,album,coverUrl,durationS,duration,source,ext,bitrate,codec,fileSize,fileSizeBytes);

@override
String toString() {
  return 'TrackDto(trackId: $trackId, songName: $songName, singers: $singers, album: $album, coverUrl: $coverUrl, durationS: $durationS, duration: $duration, source: $source, ext: $ext, bitrate: $bitrate, codec: $codec, fileSize: $fileSize, fileSizeBytes: $fileSizeBytes)';
}


}

/// @nodoc
abstract mixin class $TrackDtoCopyWith<$Res>  {
  factory $TrackDtoCopyWith(TrackDto value, $Res Function(TrackDto) _then) = _$TrackDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'track_id') String trackId,@JsonKey(name: 'song_name') String? songName, String? singers, String? album,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'duration_s') int? durationS, String? duration, String? source, String? ext, int? bitrate, String? codec,@JsonKey(name: 'file_size') String? fileSize,@JsonKey(name: 'file_size_bytes') int? fileSizeBytes
});




}
/// @nodoc
class _$TrackDtoCopyWithImpl<$Res>
    implements $TrackDtoCopyWith<$Res> {
  _$TrackDtoCopyWithImpl(this._self, this._then);

  final TrackDto _self;
  final $Res Function(TrackDto) _then;

/// Create a copy of TrackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackId = null,Object? songName = freezed,Object? singers = freezed,Object? album = freezed,Object? coverUrl = freezed,Object? durationS = freezed,Object? duration = freezed,Object? source = freezed,Object? ext = freezed,Object? bitrate = freezed,Object? codec = freezed,Object? fileSize = freezed,Object? fileSizeBytes = freezed,}) {
  return _then(_self.copyWith(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,songName: freezed == songName ? _self.songName : songName // ignore: cast_nullable_to_non_nullable
as String?,singers: freezed == singers ? _self.singers : singers // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,durationS: freezed == durationS ? _self.durationS : durationS // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,ext: freezed == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as String?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackDto].
extension TrackDtoPatterns on TrackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackDto value)  $default,){
final _that = this;
switch (_that) {
case _TrackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackDto value)?  $default,){
final _that = this;
switch (_that) {
case _TrackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'track_id')  String trackId, @JsonKey(name: 'song_name')  String? songName,  String? singers,  String? album, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'duration_s')  int? durationS,  String? duration,  String? source,  String? ext,  int? bitrate,  String? codec, @JsonKey(name: 'file_size')  String? fileSize, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackDto() when $default != null:
return $default(_that.trackId,_that.songName,_that.singers,_that.album,_that.coverUrl,_that.durationS,_that.duration,_that.source,_that.ext,_that.bitrate,_that.codec,_that.fileSize,_that.fileSizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'track_id')  String trackId, @JsonKey(name: 'song_name')  String? songName,  String? singers,  String? album, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'duration_s')  int? durationS,  String? duration,  String? source,  String? ext,  int? bitrate,  String? codec, @JsonKey(name: 'file_size')  String? fileSize, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes)  $default,) {final _that = this;
switch (_that) {
case _TrackDto():
return $default(_that.trackId,_that.songName,_that.singers,_that.album,_that.coverUrl,_that.durationS,_that.duration,_that.source,_that.ext,_that.bitrate,_that.codec,_that.fileSize,_that.fileSizeBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'track_id')  String trackId, @JsonKey(name: 'song_name')  String? songName,  String? singers,  String? album, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'duration_s')  int? durationS,  String? duration,  String? source,  String? ext,  int? bitrate,  String? codec, @JsonKey(name: 'file_size')  String? fileSize, @JsonKey(name: 'file_size_bytes')  int? fileSizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _TrackDto() when $default != null:
return $default(_that.trackId,_that.songName,_that.singers,_that.album,_that.coverUrl,_that.durationS,_that.duration,_that.source,_that.ext,_that.bitrate,_that.codec,_that.fileSize,_that.fileSizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackDto implements TrackDto {
  const _TrackDto({@JsonKey(name: 'track_id') required this.trackId, @JsonKey(name: 'song_name') this.songName, this.singers, this.album, @JsonKey(name: 'cover_url') this.coverUrl, @JsonKey(name: 'duration_s') this.durationS, this.duration, this.source, this.ext, this.bitrate, this.codec, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'file_size_bytes') this.fileSizeBytes});
  factory _TrackDto.fromJson(Map<String, dynamic> json) => _$TrackDtoFromJson(json);

@override@JsonKey(name: 'track_id') final  String trackId;
@override@JsonKey(name: 'song_name') final  String? songName;
@override final  String? singers;
@override final  String? album;
@override@JsonKey(name: 'cover_url') final  String? coverUrl;
@override@JsonKey(name: 'duration_s') final  int? durationS;
@override final  String? duration;
@override final  String? source;
@override final  String? ext;
@override final  int? bitrate;
@override final  String? codec;
@override@JsonKey(name: 'file_size') final  String? fileSize;
@override@JsonKey(name: 'file_size_bytes') final  int? fileSizeBytes;

/// Create a copy of TrackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackDtoCopyWith<_TrackDto> get copyWith => __$TrackDtoCopyWithImpl<_TrackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackDto&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.songName, songName) || other.songName == songName)&&(identical(other.singers, singers) || other.singers == singers)&&(identical(other.album, album) || other.album == album)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.durationS, durationS) || other.durationS == durationS)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.source, source) || other.source == source)&&(identical(other.ext, ext) || other.ext == ext)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileSizeBytes, fileSizeBytes) || other.fileSizeBytes == fileSizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,trackId,songName,singers,album,coverUrl,durationS,duration,source,ext,bitrate,codec,fileSize,fileSizeBytes);

@override
String toString() {
  return 'TrackDto(trackId: $trackId, songName: $songName, singers: $singers, album: $album, coverUrl: $coverUrl, durationS: $durationS, duration: $duration, source: $source, ext: $ext, bitrate: $bitrate, codec: $codec, fileSize: $fileSize, fileSizeBytes: $fileSizeBytes)';
}


}

/// @nodoc
abstract mixin class _$TrackDtoCopyWith<$Res> implements $TrackDtoCopyWith<$Res> {
  factory _$TrackDtoCopyWith(_TrackDto value, $Res Function(_TrackDto) _then) = __$TrackDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'track_id') String trackId,@JsonKey(name: 'song_name') String? songName, String? singers, String? album,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'duration_s') int? durationS, String? duration, String? source, String? ext, int? bitrate, String? codec,@JsonKey(name: 'file_size') String? fileSize,@JsonKey(name: 'file_size_bytes') int? fileSizeBytes
});




}
/// @nodoc
class __$TrackDtoCopyWithImpl<$Res>
    implements _$TrackDtoCopyWith<$Res> {
  __$TrackDtoCopyWithImpl(this._self, this._then);

  final _TrackDto _self;
  final $Res Function(_TrackDto) _then;

/// Create a copy of TrackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? songName = freezed,Object? singers = freezed,Object? album = freezed,Object? coverUrl = freezed,Object? durationS = freezed,Object? duration = freezed,Object? source = freezed,Object? ext = freezed,Object? bitrate = freezed,Object? codec = freezed,Object? fileSize = freezed,Object? fileSizeBytes = freezed,}) {
  return _then(_TrackDto(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,songName: freezed == songName ? _self.songName : songName // ignore: cast_nullable_to_non_nullable
as String?,singers: freezed == singers ? _self.singers : singers // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,durationS: freezed == durationS ? _self.durationS : durationS // ignore: cast_nullable_to_non_nullable
as int?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,ext: freezed == ext ? _self.ext : ext // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as String?,fileSizeBytes: freezed == fileSizeBytes ? _self.fileSizeBytes : fileSizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
