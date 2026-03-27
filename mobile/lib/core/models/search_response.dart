import 'package:freezed_annotation/freezed_annotation.dart';

import 'track_dto.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

/// Immutable model for the /search endpoint response.
/// Matches api/models.py SearchResponse exactly.
@freezed
abstract class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required List<TrackDto> tracks,
    required List<String> warnings,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}
