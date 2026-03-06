// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [MusicDlAudioHandler] singleton that was created in [main] and
/// injected via [ProviderScope] overrides.
///
/// The body throws [UnimplementedError] because the handler must be created
/// before [ProviderScope] is mounted (audio_session must be configured and
/// AudioService.init must complete before runApp).  The real instance is
/// supplied via `audioHandlerProvider.overrideWithValue(audioHandler)` in
/// ProviderScope.

@ProviderFor(audioHandler)
final audioHandlerProvider = AudioHandlerProvider._();

/// Provides the [MusicDlAudioHandler] singleton that was created in [main] and
/// injected via [ProviderScope] overrides.
///
/// The body throws [UnimplementedError] because the handler must be created
/// before [ProviderScope] is mounted (audio_session must be configured and
/// AudioService.init must complete before runApp).  The real instance is
/// supplied via `audioHandlerProvider.overrideWithValue(audioHandler)` in
/// ProviderScope.

final class AudioHandlerProvider
    extends
        $FunctionalProvider<
          MusicDlAudioHandler,
          MusicDlAudioHandler,
          MusicDlAudioHandler
        >
    with $Provider<MusicDlAudioHandler> {
  /// Provides the [MusicDlAudioHandler] singleton that was created in [main] and
  /// injected via [ProviderScope] overrides.
  ///
  /// The body throws [UnimplementedError] because the handler must be created
  /// before [ProviderScope] is mounted (audio_session must be configured and
  /// AudioService.init must complete before runApp).  The real instance is
  /// supplied via `audioHandlerProvider.overrideWithValue(audioHandler)` in
  /// ProviderScope.
  AudioHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioHandlerHash();

  @$internal
  @override
  $ProviderElement<MusicDlAudioHandler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MusicDlAudioHandler create(Ref ref) {
    return audioHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicDlAudioHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicDlAudioHandler>(value),
    );
  }
}

String _$audioHandlerHash() => r'1b3142eeee9d4ad00319ffbf44c3ba27d0573168';

/// Returns the [just_audio] [AudioPlayer] from the handler singleton.
///
/// All code that needs the player should read this provider so they all
/// share the exact same [AudioPlayer] instance managed by the handler.

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

/// Returns the [just_audio] [AudioPlayer] from the handler singleton.
///
/// All code that needs the player should read this provider so they all
/// share the exact same [AudioPlayer] instance managed by the handler.

final class AudioPlayerProvider
    extends $FunctionalProvider<dynamic, dynamic, dynamic>
    with $Provider<dynamic> {
  /// Returns the [just_audio] [AudioPlayer] from the handler singleton.
  ///
  /// All code that needs the player should read this provider so they all
  /// share the exact same [AudioPlayer] instance managed by the handler.
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
  $ProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  dynamic create(Ref ref) {
    return audioPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(dynamic value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<dynamic>(value),
    );
  }
}

String _$audioPlayerHash() => r'750101b9d0eae1721a53c2780079add10c8c2f58';

/// Tracks the currently playing/loading [TrackDto].
///
/// null = nothing is playing. Mini player bar watches this to show/hide.
/// Search screen sets this when a tile is tapped.
///
/// keepAlive: true ensures the current track survives tab navigation.

@ProviderFor(CurrentTrack)
final currentTrackProvider = CurrentTrackProvider._();

/// Tracks the currently playing/loading [TrackDto].
///
/// null = nothing is playing. Mini player bar watches this to show/hide.
/// Search screen sets this when a tile is tapped.
///
/// keepAlive: true ensures the current track survives tab navigation.
final class CurrentTrackProvider
    extends $NotifierProvider<CurrentTrack, TrackDto?> {
  /// Tracks the currently playing/loading [TrackDto].
  ///
  /// null = nothing is playing. Mini player bar watches this to show/hide.
  /// Search screen sets this when a tile is tapped.
  ///
  /// keepAlive: true ensures the current track survives tab navigation.
  CurrentTrackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTrackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTrackHash();

  @$internal
  @override
  CurrentTrack create() => CurrentTrack();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackDto? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackDto?>(value),
    );
  }
}

String _$currentTrackHash() => r'f73c7f9b17b1f7e67f645044d61dbba28667546c';

/// Tracks the currently playing/loading [TrackDto].
///
/// null = nothing is playing. Mini player bar watches this to show/hide.
/// Search screen sets this when a tile is tapped.
///
/// keepAlive: true ensures the current track survives tab navigation.

abstract class _$CurrentTrack extends $Notifier<TrackDto?> {
  TrackDto? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TrackDto?, TrackDto?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackDto?, TrackDto?>,
              TrackDto?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
