import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_dto.freezed.dart';
part 'track_dto.g.dart';

/// Immutable data model for a track returned by the backend API.
/// Fields match api/models.py TrackDTO exactly (snake_case JSON, camelCase Dart).
@freezed
abstract class TrackDto with _$TrackDto {
  const factory TrackDto({
    @JsonKey(name: 'track_id') required String trackId,
    @JsonKey(name: 'song_name') String? songName,
    String? singers,
    String? album,
    @JsonKey(name: 'cover_url') String? coverUrl,
    @JsonKey(name: 'duration_s') int? durationS,
    String? duration,
    String? source,
    String? ext,
    int? bitrate,
    String? codec,
    @JsonKey(name: 'file_size') String? fileSize,
    @JsonKey(name: 'file_size_bytes') int? fileSizeBytes,
  }) = _TrackDto;

  factory TrackDto.fromJson(Map<String, dynamic> json) =>
      _$TrackDtoFromJson(json);
}
