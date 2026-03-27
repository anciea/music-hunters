// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the list of user-created playlists and their tracks.
///
/// State is [List<PlaylistModel>] loaded from SQLite, including aggregated
/// track counts and up to 4 cover URLs per playlist.
///
/// All mutations reload state from the database immediately for consistency.

@ProviderFor(Playlists)
final playlistsProvider = PlaylistsProvider._();

/// Manages the list of user-created playlists and their tracks.
///
/// State is [List<PlaylistModel>] loaded from SQLite, including aggregated
/// track counts and up to 4 cover URLs per playlist.
///
/// All mutations reload state from the database immediately for consistency.
final class PlaylistsProvider
    extends $NotifierProvider<Playlists, List<PlaylistModel>> {
  /// Manages the list of user-created playlists and their tracks.
  ///
  /// State is [List<PlaylistModel>] loaded from SQLite, including aggregated
  /// track counts and up to 4 cover URLs per playlist.
  ///
  /// All mutations reload state from the database immediately for consistency.
  PlaylistsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistsHash();

  @$internal
  @override
  Playlists create() => Playlists();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PlaylistModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PlaylistModel>>(value),
    );
  }
}

String _$playlistsHash() => r'b90d87765016bd2404b02a240c8b932dabd068af';

/// Manages the list of user-created playlists and their tracks.
///
/// State is [List<PlaylistModel>] loaded from SQLite, including aggregated
/// track counts and up to 4 cover URLs per playlist.
///
/// All mutations reload state from the database immediately for consistency.

abstract class _$Playlists extends $Notifier<List<PlaylistModel>> {
  List<PlaylistModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PlaylistModel>, List<PlaylistModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PlaylistModel>, List<PlaylistModel>>,
              List<PlaylistModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
