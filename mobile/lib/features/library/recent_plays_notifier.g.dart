// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_plays_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the recently played tracks list.
///
/// State is [List<RecentPlay>] loaded from SQLite, sorted by most recent first,
/// capped at 200 entries. Each play is stored with a Unix epoch millisecond
/// timestamp.
///
/// Uses INSERT OR REPLACE so replaying the same track moves it to the top
/// without creating duplicates (enforced by the UNIQUE(track_id, source)
/// constraint on the recent_plays table).

@ProviderFor(RecentPlays)
final recentPlaysProvider = RecentPlaysProvider._();

/// Manages the recently played tracks list.
///
/// State is [List<RecentPlay>] loaded from SQLite, sorted by most recent first,
/// capped at 200 entries. Each play is stored with a Unix epoch millisecond
/// timestamp.
///
/// Uses INSERT OR REPLACE so replaying the same track moves it to the top
/// without creating duplicates (enforced by the UNIQUE(track_id, source)
/// constraint on the recent_plays table).
final class RecentPlaysProvider
    extends $NotifierProvider<RecentPlays, List<RecentPlay>> {
  /// Manages the recently played tracks list.
  ///
  /// State is [List<RecentPlay>] loaded from SQLite, sorted by most recent first,
  /// capped at 200 entries. Each play is stored with a Unix epoch millisecond
  /// timestamp.
  ///
  /// Uses INSERT OR REPLACE so replaying the same track moves it to the top
  /// without creating duplicates (enforced by the UNIQUE(track_id, source)
  /// constraint on the recent_plays table).
  RecentPlaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentPlaysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentPlaysHash();

  @$internal
  @override
  RecentPlays create() => RecentPlays();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<RecentPlay> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<RecentPlay>>(value),
    );
  }
}

String _$recentPlaysHash() => r'0e2aaa04e5c2505a5fcdea22fc19380f87b6a650';

/// Manages the recently played tracks list.
///
/// State is [List<RecentPlay>] loaded from SQLite, sorted by most recent first,
/// capped at 200 entries. Each play is stored with a Unix epoch millisecond
/// timestamp.
///
/// Uses INSERT OR REPLACE so replaying the same track moves it to the top
/// without creating duplicates (enforced by the UNIQUE(track_id, source)
/// constraint on the recent_plays table).

abstract class _$RecentPlays extends $Notifier<List<RecentPlay>> {
  List<RecentPlay> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<RecentPlay>, List<RecentPlay>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<RecentPlay>, List<RecentPlay>>,
              List<RecentPlay>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
