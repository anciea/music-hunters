import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_model.freezed.dart';

/// Immutable model for a user-created playlist, including aggregated metadata
/// (track count and up to 4 cover URLs) fetched in a single SQL query.
@freezed
abstract class PlaylistModel with _$PlaylistModel {
  const factory PlaylistModel({
    required int id,
    required String name,
    required int createdAt,
    @Default(0) int trackCount,
    @Default([]) List<String?> coverUrls,
  }) = _PlaylistModel;
}
