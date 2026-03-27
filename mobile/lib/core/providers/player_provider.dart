import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
