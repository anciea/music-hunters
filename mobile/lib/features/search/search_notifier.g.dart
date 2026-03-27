// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier managing search state.
///
/// State lifecycle:
///   null  — no search submitted yet (first launch)
///   loading — search in progress (shimmer)
///   data(SearchResponse) — results received (list or empty)
///   error — API call failed (retry button)

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierProvider._();

/// AsyncNotifier managing search state.
///
/// State lifecycle:
///   null  — no search submitted yet (first launch)
///   loading — search in progress (shimmer)
///   data(SearchResponse) — results received (list or empty)
///   error — API call failed (retry button)
final class SearchNotifierProvider
    extends $AsyncNotifierProvider<SearchNotifier, SearchResponse?> {
  /// AsyncNotifier managing search state.
  ///
  /// State lifecycle:
  ///   null  — no search submitted yet (first launch)
  ///   loading — search in progress (shimmer)
  ///   data(SearchResponse) — results received (list or empty)
  ///   error — API call failed (retry button)
  SearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();
}

String _$searchNotifierHash() => r'1e08bcd61951a4ee3bf991bcaa7d9519e7a6c84e';

/// AsyncNotifier managing search state.
///
/// State lifecycle:
///   null  — no search submitted yet (first launch)
///   loading — search in progress (shimmer)
///   data(SearchResponse) — results received (list or empty)
///   error — API call failed (retry button)

abstract class _$SearchNotifier extends $AsyncNotifier<SearchResponse?> {
  FutureOr<SearchResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SearchResponse?>, SearchResponse?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchResponse?>, SearchResponse?>,
              AsyncValue<SearchResponse?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
