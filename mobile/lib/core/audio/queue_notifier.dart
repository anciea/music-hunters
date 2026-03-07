import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../models/track_dto.dart';
import '../providers/player_provider.dart';
import 'audio_handler.dart';

part 'queue_notifier.g.dart';

/// Manages the playback queue and keeps the [just_audio] player's internal
/// playlist in sync with the [List<TrackDto>] state.
///
/// All mutations go through this notifier — never call player playlist methods
/// directly from the UI.
///
/// [keepAlive: true] ensures the queue survives tab navigation.
@Riverpod(keepAlive: true)
class Queue extends _$Queue {
  @override
  List<TrackDto> build() => [];

  // ---------------------------------------------------------------------------
  // Internal helper
  // ---------------------------------------------------------------------------

  MusicDlAudioHandler get _handler => ref.read(audioHandlerProvider);

  /// Converts a [TrackDto] to an [AudioSource] with a [MediaItem] tag.
  ///
  /// The tag is the source of truth for the now-playing metadata displayed in
  /// the OS notification — [MusicDlAudioHandler] reads it from
  /// [AudioPlayer.sequence[index].tag] whenever the current index changes.
  AudioSource _toAudioSource(TrackDto track) {
    return AudioSource.uri(
      Uri.parse(
        '${AppConfig.apiBaseUrl}/stream'
        '?track_id=${Uri.encodeComponent(track.trackId)}'
        '&source=${Uri.encodeComponent(track.source ?? '')}',
      ),
      headers: {'X-API-Key': AppConfig.apiKey},
      tag: MediaItem(
        id: '${track.source ?? ''}_${track.trackId}',
        title: track.songName ?? 'Unknown',
        artist: track.singers,
        album: track.album,
        artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
        duration: track.durationS != null
            ? Duration(seconds: track.durationS!.round())
            : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Playback mutations
  // ---------------------------------------------------------------------------

  /// Replaces the entire queue with [track] and starts playback immediately.
  ///
  /// This is the primary entry point from the search screen.  All existing
  /// queue items are discarded.
  Future<void> playNow(TrackDto track) async {
    final handler = _handler;
    state = [track];
    await handler.player.clearAudioSources();
    await handler.player.addAudioSource(_toAudioSource(track));
    await handler.skipToQueueItem(0);
    await handler.play();
    ref.read(currentTrackProvider.notifier).setTrack(track);
  }

  /// Inserts [track] immediately after the currently playing item and keeps
  /// it ready to play next.
  Future<void> playNext(TrackDto track) async {
    final handler = _handler;
    final currentIndex = handler.player.currentIndex ?? -1;
    final insertAt = currentIndex + 1;

    final newState = List<TrackDto>.from(state);
    newState.insert(insertAt, track);
    state = newState;

    await handler.player.insertAudioSource(insertAt, _toAudioSource(track));
  }

  /// Appends [track] to the end of the queue.
  Future<void> addToQueue(TrackDto track) async {
    final handler = _handler;
    state = [...state, track];
    await handler.player.addAudioSource(_toAudioSource(track));
  }

  /// Removes the track at [index] from the queue.
  Future<void> removeAt(int index) async {
    final handler = _handler;
    final newState = List<TrackDto>.from(state)..removeAt(index);
    state = newState;
    await handler.player.removeAudioSourceAt(index);
  }

  /// Moves a track from [oldIndex] to [newIndex].
  ///
  /// Adjusts for [ReorderableListView]'s convention where the new index is
  /// reported one higher than expected when moving downward.
  Future<void> move(int oldIndex, int newIndex) async {
    final handler = _handler;
    // ReorderableListView reports newIndex as the position after the item is
    // removed — when moving an item downward the target index is one too high.
    final adjustedNew = newIndex > oldIndex ? newIndex - 1 : newIndex;

    final newState = List<TrackDto>.from(state);
    final item = newState.removeAt(oldIndex);
    newState.insert(adjustedNew, item);
    state = newState;

    await handler.player.moveAudioSource(oldIndex, adjustedNew);
  }
}
