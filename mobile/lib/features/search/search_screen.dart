import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/config/app_config.dart';
import '../../core/models/track_dto.dart';
import '../../core/providers/player_provider.dart';
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

  Future<void> _playTrack(TrackDto track) async {
    final player = ref.read(audioPlayerProvider);
    try {
      await player.stop();
      ref.read(currentTrackProvider.notifier).setTrack(track);
      final streamUrl = '${AppConfig.apiBaseUrl}/stream/${track.trackId}';
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          headers: {'X-API-Key': AppConfig.apiKey},
        ),
      );
      await player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't play this track")),
        );
      }
    }
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
