// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the playback queue and keeps the [just_audio] player's internal
/// playlist in sync with the [List<TrackDto>] state.
///
/// All mutations go through this notifier — never call player playlist methods
/// directly from the UI.
///
/// [keepAlive: true] ensures the queue survives tab navigation.

@ProviderFor(Queue)
final queueProvider = QueueProvider._();

/// Manages the playback queue and keeps the [just_audio] player's internal
/// playlist in sync with the [List<TrackDto>] state.
///
/// All mutations go through this notifier — never call player playlist methods
/// directly from the UI.
///
/// [keepAlive: true] ensures the queue survives tab navigation.
final class QueueProvider extends $NotifierProvider<Queue, List<TrackDto>> {
  /// Manages the playback queue and keeps the [just_audio] player's internal
  /// playlist in sync with the [List<TrackDto>] state.
  ///
  /// All mutations go through this notifier — never call player playlist methods
  /// directly from the UI.
  ///
  /// [keepAlive: true] ensures the queue survives tab navigation.
  QueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueHash();

  @$internal
  @override
  Queue create() => Queue();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TrackDto> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TrackDto>>(value),
    );
  }
}

String _$queueHash() => r'0b2157129066ef634788e2744a72bc7b6ea81bda';

/// Manages the playback queue and keeps the [just_audio] player's internal
/// playlist in sync with the [List<TrackDto>] state.
///
/// All mutations go through this notifier — never call player playlist methods
/// directly from the UI.
///
/// [keepAlive: true] ensures the queue survives tab navigation.

abstract class _$Queue extends $Notifier<List<TrackDto>> {
  List<TrackDto> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<TrackDto>, List<TrackDto>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TrackDto>, List<TrackDto>>,
              List<TrackDto>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
