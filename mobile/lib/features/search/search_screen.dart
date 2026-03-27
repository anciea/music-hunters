import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/queue_notifier.dart';
import '../../core/models/track_dto.dart';
import 'search_notifier.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'widgets/shimmer_list.dart';
import 'widgets/track_list_tile.dart';

/// Full search screen: search bar + results list.
///
/// State flows:
///   null (no search) -> EmptyState(hasSearched: false)
///   loading          -> ShimmerList
///   data (empty)     -> EmptyState(hasSearched: true)
///   data (results)   -> ListView of TrackListTile
///   error            -> ErrorState with retry button
///
/// Tapping a track calls [_playTrack] which goes through
/// [queueProvider.notifier.playNow] — never direct player calls.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch(String text) {
    if (text.trim().isEmpty) return;
    ref.read(searchProvider.notifier).search(text);
  }

  /// Plays [track] immediately by delegating to [QueueNotifier.playNow].
  ///
  /// QueueNotifier handles stop → clear → add source → seek(0) → play in one
  /// atomic operation, so search_screen has no direct AudioPlayer dependency.
  void _playTrack(TrackDto track) {
    ref.read(queueProvider.notifier).playNow(track);
  }

  /// Shows the long-press context menu for [track] with Play Now / Play Next /
  /// Add to Queue options.
  void _showTrackContextMenu(BuildContext context, TrackDto track) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.play_arrow,
                color: Color(0xFF9E9E9E),
              ),
              title: const Text(
                'Play Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(queueProvider.notifier).playNow(track);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.playlist_play,
                color: Color(0xFF9E9E9E),
              ),
              title: const Text(
                'Play Next',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(queueProvider.notifier).playNext(track);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_to_queue,
                color: Color(0xFF9E9E9E),
              ),
              title: const Text(
                'Add to Queue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(queueProvider.notifier).addToQueue(track);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: 'Search songs, artists, albums...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9E9E9E),
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return Semantics(
                      label: 'Clear search',
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _controller.clear();
                        },
                      ),
                    );
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Results area
          Expanded(
            child: searchState.when(
              data: (response) {
                if (response == null) {
                  return const EmptyState(hasSearched: false);
                }
                if (response.tracks.isEmpty) {
                  return const EmptyState(hasSearched: true);
                }
                return ListView.builder(
                  itemCount: response.tracks.length,
                  itemBuilder: (context, index) {
                    final track = response.tracks[index];
                    return TrackListTile(
                      track: track,
                      onTap: () => _playTrack(track),
                      onLongPress: () =>
                          _showTrackContextMenu(context, track),
                    );
                  },
                );
              },
              loading: () => const ShimmerList(),
              error: (e, _) => ErrorState(
                onRetry: () =>
                    ref.read(searchProvider.notifier).search(
                          _controller.text,
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
