import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/track_dto.dart';

part 'player_provider.g.dart';

/// Singleton [AudioPlayer] that survives navigation.
///
/// keepAlive: true is critical — Riverpod 3.x defaults to autoDispose,
/// which would stop playback when the user switches away from the search tab.
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
}

/// Tracks the currently playing/loading [TrackDto].
///
/// null = nothing is playing. Mini player bar watches this to show/hide.
/// Search screen sets this when a tile is tapped.
///
/// keepAlive: true ensures the current track survives tab navigation.
@Riverpod(keepAlive: true)
class CurrentTrack extends _$CurrentTrack {
  @override
  TrackDto? build() => null;

  void setTrack(TrackDto? track) {
    state = track;
  }
}
