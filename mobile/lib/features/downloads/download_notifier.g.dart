// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the download state for all tracks.
///
/// State is a map from track key ('source_trackId') to [DownloadEntry].
/// On build, hydrates from the local SQLite database — verifying each file
/// still exists on disk and cleaning up stale rows.
///
/// Enforces a maximum of 3 concurrent downloads.

@ProviderFor(Downloads)
final downloadsProvider = DownloadsProvider._();

/// Manages the download state for all tracks.
///
/// State is a map from track key ('source_trackId') to [DownloadEntry].
/// On build, hydrates from the local SQLite database — verifying each file
/// still exists on disk and cleaning up stale rows.
///
/// Enforces a maximum of 3 concurrent downloads.
final class DownloadsProvider
    extends $NotifierProvider<Downloads, Map<String, DownloadEntry>> {
  /// Manages the download state for all tracks.
  ///
  /// State is a map from track key ('source_trackId') to [DownloadEntry].
  /// On build, hydrates from the local SQLite database — verifying each file
  /// still exists on disk and cleaning up stale rows.
  ///
  /// Enforces a maximum of 3 concurrent downloads.
  DownloadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadsHash();

  @$internal
  @override
  Downloads create() => Downloads();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DownloadEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DownloadEntry>>(value),
    );
  }
}

String _$downloadsHash() => r'707e00b5f26b8a5b9611f4307a4ba099d8787a6b';

/// Manages the download state for all tracks.
///
/// State is a map from track key ('source_trackId') to [DownloadEntry].
/// On build, hydrates from the local SQLite database — verifying each file
/// still exists on disk and cleaning up stale rows.
///
/// Enforces a maximum of 3 concurrent downloads.

abstract class _$Downloads extends $Notifier<Map<String, DownloadEntry>> {
  Map<String, DownloadEntry> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, DownloadEntry>, Map<String, DownloadEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, DownloadEntry>,
                Map<String, DownloadEntry>
              >,
              Map<String, DownloadEntry>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
