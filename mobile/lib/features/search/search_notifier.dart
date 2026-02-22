import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/music_api.dart';
import '../../core/models/search_response.dart';

part 'search_notifier.g.dart';

/// AsyncNotifier managing search state.
///
/// State lifecycle:
///   null  — no search submitted yet (first launch)
///   loading — search in progress (shimmer)
///   data(SearchResponse) — results received (list or empty)
///   error — API call failed (retry button)
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  FutureOr<SearchResponse?> build() => null;

  /// Triggers a search for [query] against the backend API.
  ///
  /// Does nothing when [query] is blank after trimming.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(musicApiProvider).searchTracks(trimmed),
    );
  }
}
