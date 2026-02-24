import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../core/providers/player_provider.dart';
import '../features/search/widgets/source_badge.dart';

/// Persistent mini player bar shown above the bottom NavigationBar.
///
/// Reads [currentTrackProvider] — hidden (SizedBox.shrink) when null.
/// When a track is set, renders 64dp bar with album art, title, artist,
/// and a play/pause toggle button that controls [audioPlayerProvider].
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);

    // Hidden when nothing is playing
    if (track == null) return const SizedBox.shrink();

    final player = ref.read(audioPlayerProvider);

    return Semantics(
      label: 'Now playing: ${track.songName ?? 'Unknown'} by ${track.singers ?? 'Unknown artist'}',
      child: Container(
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
            // Play/pause toggle — listens to live playerStateStream
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final isPlaying = playerState?.playing ?? false;

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
                        player.pause();
                      } else {
                        player.play();
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
