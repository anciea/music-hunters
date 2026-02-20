// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton [AudioPlayer] that survives navigation.
///
/// keepAlive: true is critical — Riverpod 3.x defaults to autoDispose,
/// which would stop playback when the user switches away from the search tab.

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

/// Singleton [AudioPlayer] that survives navigation.
///
/// keepAlive: true is critical — Riverpod 3.x defaults to autoDispose,
/// which would stop playback when the user switches away from the search tab.

final class AudioPlayerProvider
    extends $FunctionalProvider<AudioPlayer, AudioPlayer, AudioPlayer>
    with $Provider<AudioPlayer> {
  /// Singleton [AudioPlayer] that survives navigation.
  ///
  /// keepAlive: true is critical — Riverpod 3.x defaults to autoDispose,
  /// which would stop playback when the user switches away from the search tab.
  AudioPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayer create(Ref ref) {
    return audioPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer>(value),
    );
  }
}

String _$audioPlayerHash() => r'da4907d740d3974621d680b1ce2ac2a61956bb40';
