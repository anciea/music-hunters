// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrackDto _$TrackDtoFromJson(Map<String, dynamic> json) => _TrackDto(
  trackId: json['track_id'] as String,
  songName: json['song_name'] as String?,
  singers: json['singers'] as String?,
  album: json['album'] as String?,
  coverUrl: json['cover_url'] as String?,
  durationS: (json['duration_s'] as num?)?.toInt(),
  duration: json['duration'] as String?,
  source: json['source'] as String?,
  ext: json['ext'] as String?,
  bitrate: (json['bitrate'] as num?)?.toInt(),
  codec: json['codec'] as String?,
  fileSize: json['file_size'] as String?,
  fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrackDtoToJson(_TrackDto instance) => <String, dynamic>{
  'track_id': instance.trackId,
  'song_name': instance.songName,
  'singers': instance.singers,
  'album': instance.album,
  'cover_url': instance.coverUrl,
  'duration_s': instance.durationS,
  'duration': instance.duration,
  'source': instance.source,
  'ext': instance.ext,
  'bitrate': instance.bitrate,
  'codec': instance.codec,
  'file_size': instance.fileSize,
  'file_size_bytes': instance.fileSizeBytes,
};
