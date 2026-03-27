import 'package:freezed_annotation/freezed_annotation.dart';

import 'track_dto.dart';

part 'recent_play.freezed.dart';

/// Immutable model pairing a [TrackDto] with the Unix epoch millisecond
/// timestamp at which it was played.
@freezed
abstract class RecentPlay with _$RecentPlay {
  const factory RecentPlay({
    required TrackDto track,
    required int playedAt,
  }) = _RecentPlay;
}
