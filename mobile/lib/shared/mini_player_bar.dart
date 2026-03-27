import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../core/providers/player_provider.dart';
import '../features/player/full_player_sheet.dart';
import '../features/search/widgets/source_badge.dart';

/// Persistent mini player bar shown above the bottom NavigationBar.
///
/// Reads [currentTrackProvider] — hidden (SizedBox.shrink) when null.
/// When a track is set, renders 64dp bar with:
///   - Album art (40x40dp)
///   - Title + artist text
///   - Play/pause toggle (or CircularProgressIndicator when buffering/loading)
///   - 2dp LinearProgressIndicator at bottom of bar
///   - Tap anywhere to open full player DraggableScrollableSheet
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);

    // Hidden when nothing is playing
    if (track == null) return const SizedBox.shrink();

    final handler = ref.read(audioHandlerProvider);
    final player = handler.player;

    return Semantics(
      label:
          'Now playing: ${track.songName ?? 'Unknown'} by ${track.singers ?? 'Unknown artist'}',
      child: Semantics(
        label: 'Open full player',
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => DraggableScrollableSheet(
                initialChildSize: 1.0,
                minChildSize: 0.0,
                maxChildSize: 1.0,
                builder: (context, scrollController) =>
                    const FullPlayerSheet(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Album art — 40x40dp with 4dp rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: track.coverUrl ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 40,
                          height: 40,
                          color: const Color(0xFF424242),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 40,
                          height: 40,
                          color: badgeColorFor(track.source ?? ''),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Track title and artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            track.songName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track.singers ?? 'Unknown artist',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play/pause toggle or loading spinner
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState =
                            playerState?.processingState ??
                                ProcessingState.idle;
                        final isPlaying = playerState?.playing ?? false;

                        final isLoadingOrBuffering =
                            processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering;

                        if (isLoadingOrBuffering) {
                          return Padding(
                            padding: const EdgeInsets.all(14),
                            child: Semantics(
                              label: 'Loading audio',
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1DB954),
                                ),
                              ),
                            ),
                          );
                        }

                        return Semantics(
                          label: isPlaying ? 'Pause' : 'Play',
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: isPlaying
                                  ? const Color(0xFF1DB954)
                                  : Colors.white,
                              size: 32,
                            ),
                            iconSize: 32,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                handler.pause();
                              } else {
                                handler.play();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 2dp progress line pinned at bottom of bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: StreamBuilder<Duration?>(
                  stream: player.durationStream,
                  builder: (context, durationSnapshot) {
                    final duration =
                        durationSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, positionSnapshot) {
                        final position =
                            positionSnapshot.data ?? Duration.zero;
                        final durationMs =
                            duration.inMilliseconds.toDouble();
                        final value = durationMs > 0
                            ? (position.inMilliseconds.toDouble() /
                                    durationMs)
                                .clamp(0.0, 1.0)
                            : 0.0;
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 2,
                          color: const Color(0xFF1DB954),
                          backgroundColor: const Color(0xFF2A2A2A),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
