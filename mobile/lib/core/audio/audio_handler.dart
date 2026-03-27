import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// [MusicDlAudioHandler] wraps a [just_audio] [AudioPlayer] and bridges it to
/// [audio_service], enabling background playback and OS notification controls.
///
/// Design notes:
/// - All playback goes through this handler — never call _player directly from UI.
/// - MediaItems are read from the tag attached to each [AudioSource] in
///   the player's internal playlist rather than from [queue.value], which is
///   never populated by [BaseAudioHandler] and would always be empty.
/// - The player is initialised with an empty playlist via [setAudioSources([])].
///   [QueueNotifier] mutates the playlist using addAudioSource,
///   insertAudioSource, removeAudioSourceAt, and moveAudioSource
///   directly on the player (ConcatenatingAudioSource is deprecated in
///   just_audio 0.10.x).
class MusicDlAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  int _retryCount = 0;

  /// Broadcast stream that emits error messages suitable for SnackBar display.
  final StreamController<String> errorStream =
      StreamController<String>.broadcast();

  MusicDlAudioHandler(this._player) {
    // Initialise the player with an empty playlist.  QueueNotifier will add
    // sources as the user queues tracks.
    _player.setAudioSources([], preload: false);

    // Forward playback state changes to audio_service so the OS notification
    // reflects the current play/pause/buffering state.
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: _handlePlayerError,
    );

    // Populate mediaItem from the tag on the current AudioSource whenever the
    // track index changes.  Using the tag is the only reliable way because
    // BaseAudioHandler.queue is a BehaviorSubject we never populate.
    _player.currentIndexStream.listen((index) {
      if (index == null) return;
      final sequence = _player.sequence;
      if (sequence.isEmpty || index >= sequence.length) return;
      final tag = sequence[index].tag;
      if (tag is MediaItem) {
        mediaItem.add(tag);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Public getters
  // ---------------------------------------------------------------------------

  /// The underlying [AudioPlayer] — exposed so UI widgets can subscribe to
  /// position/duration/buffering streams directly, and so [QueueNotifier] can
  /// mutate the playlist via [AudioPlayer.addAudioSource] etc.
  AudioPlayer get player => _player;

  // ---------------------------------------------------------------------------
  // BaseAudioHandler overrides
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player.setShuffleModeEnabled(
      shuffleMode == AudioServiceShuffleMode.all,
    );
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      _ => LoopMode.off,
    };
    await _player.setLoopMode(loopMode);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Maps just_audio [PlaybackEvent] to an [audio_service] [PlaybackState] and
  /// broadcasts it to the OS notification / lock screen.
  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    final processingState = _mapProcessingState(_player.processingState);

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  /// Handles player errors — retries once, then emits to [errorStream].
  void _handlePlayerError(Object error, StackTrace stackTrace) {
    if (_retryCount < 1) {
      _retryCount++;
      Future.delayed(const Duration(milliseconds: 500), () async {
        await _player.seek(Duration.zero);
        await _player.play();
      });
    } else {
      _retryCount = 0;
      errorStream.add('Playback error: $error');
    }
  }
}
