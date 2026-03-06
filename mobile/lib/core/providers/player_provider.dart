import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../audio/audio_handler.dart';
import '../models/track_dto.dart';

part 'player_provider.g.dart';

/// Provides the [MusicDlAudioHandler] singleton that was created in [main] and
/// injected via [ProviderScope] overrides.
///
/// The body throws [UnimplementedError] because the handler must be created
/// before [ProviderScope] is mounted (audio_session must be configured and
/// AudioService.init must complete before runApp).  The real instance is
/// supplied via `audioHandlerProvider.overrideWithValue(audioHandler)` in
/// ProviderScope.
@Riverpod(keepAlive: true)
MusicDlAudioHandler audioHandler(Ref ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden in ProviderScope',
  );
}

/// Returns the [just_audio] [AudioPlayer] from the handler singleton.
///
/// All code that needs the player should read this provider so they all
/// share the exact same [AudioPlayer] instance managed by the handler.
@Riverpod(keepAlive: true)
dynamic audioPlayer(Ref ref) {
  return ref.read(audioHandlerProvider).player;
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
