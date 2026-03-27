import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/models/download_entry.dart';
import '../../core/models/track_dto.dart';
import '../../core/providers/player_provider.dart';
import '../../features/downloads/download_notifier.dart';
import '../../features/library/dialogs/playlist_picker_sheet.dart';
import '../../features/search/widgets/source_badge.dart';
import 'queue_bottom_sheet.dart';
import 'seek_bar.dart';

/// Full-screen player overlay presented as a [DraggableScrollableSheet].
///
/// Opened by tapping the mini player bar.  Swipe down to dismiss.
/// All playback actions go through [audioHandlerProvider] — never direct
/// player calls from UI.
///
/// Layout (top to bottom):
///   1. Drag handle
///   2. Source + format row
///   3. Album art (300x300dp)
///   4. Track title + artist
///   5. SeekBar
///   6. Main controls row (shuffle / prev / play-pause / next / repeat)
///   7. Secondary controls row (queue button)
class FullPlayerSheet extends ConsumerWidget {
  const FullPlayerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.read(audioHandlerProvider);
    final track = ref.watch(currentTrackProvider);

    return Semantics(
      container: true,
      label: 'Full player',
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // 2. Source + format row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (track?.source != null && track!.source!.isNotEmpty)
                      SourceBadge(source: track.source!),
                    if (track != null &&
                        (track.ext != null || track.bitrate != null)) ...[
                      const SizedBox(width: 8),
                      _FormatChip(track: track),
                    ],
                  ],
                ),
              ),

              // 3. Album art — 300x300dp centered with 24dp vertical margin
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: track?.coverUrl != null && track!.coverUrl!.isNotEmpty
                        ? Semantics(
                            label:
                                '${track.songName ?? 'Unknown'} album art',
                            child: CachedNetworkImage(
                              imageUrl: track.coverUrl!,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _AlbumArtFallback(
                                source: track.source ?? '',
                              ),
                              errorWidget: (context, url, error) =>
                                  _AlbumArtFallback(
                                source: track.source ?? '',
                              ),
                            ),
                          )
                        : _AlbumArtFallback(source: track?.source ?? ''),
                  ),
                ),
              ),

              // 4. Track title + artist
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track?.songName ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track?.singers ?? 'Unknown artist',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 5. SeekBar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SeekBar(),
              ),

              // 6. Main controls row
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle button
                    StreamBuilder<bool>(
                      stream: handler.player.shuffleModeEnabledStream,
                      builder: (context, snapshot) {
                        final shuffleOn = snapshot.data ?? false;
                        return Semantics(
                          label: shuffleOn ? 'Shuffle on' : 'Shuffle off',
                          child: IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: shuffleOn
                                  ? const Color(0xFF1DB954)
                                  : Colors.white,
                            ),
                            iconSize: 28,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: () {
                              handler.setShuffleMode(
                                shuffleOn
                                    ? AudioServiceShuffleMode.none
                                    : AudioServiceShuffleMode.all,
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Skip previous button
                    StreamBuilder<SequenceState?>(
                      stream: handler.player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final seqState = snapshot.data;
                        final currentIndex = seqState?.currentIndex ?? 0;
                        final loopMode = handler.player.loopMode;
                        final canSkipPrev =
                            currentIndex > 0 || loopMode != LoopMode.off;
                        return Semantics(
                          label: 'Previous track',
                          child: IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: canSkipPrev
                                  ? Colors.white
                                  : const Color(0xFF424242),
                            ),
                            iconSize: 28,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: canSkipPrev
                                ? () => handler.skipToPrevious()
                                : null,
                          ),
                        );
                      },
                    ),

                    // Play/pause button — 56dp touch target
                    StreamBuilder<PlayerState>(
                      stream: handler.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState =
                            playerState?.processingState ??
                                ProcessingState.idle;
                        final isPlaying = playerState?.playing ?? false;

                        final isLoadingOrBuffering =
                            processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering;

                        Widget icon;
                        VoidCallback? onPressed;

                        if (isLoadingOrBuffering) {
                          icon = Semantics(
                            label: 'Loading audio',
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                          );
                          onPressed = null;
                        } else if (isPlaying) {
                          icon = const Icon(
                            Icons.pause,
                            color: Color(0xFF1DB954),
                            size: 32,
                          );
                          onPressed = () => handler.pause();
                        } else {
                          icon = const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          );
                          onPressed = () => handler.play();
                        }

                        return Semantics(
                          label: isPlaying ? 'Pause' : 'Play',
                          child: IconButton(
                            icon: icon,
                            iconSize: 32,
                            constraints: const BoxConstraints(
                              minWidth: 56,
                              minHeight: 56,
                            ),
                            onPressed: onPressed,
                          ),
                        );
                      },
                    ),

                    // Skip next button
                    StreamBuilder<SequenceState?>(
                      stream: handler.player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final seqState = snapshot.data;
                        final sequence = seqState?.sequence ?? [];
                        final currentIndex = seqState?.currentIndex ?? 0;
                        final loopMode = handler.player.loopMode;
                        final canSkipNext =
                            currentIndex < sequence.length - 1 ||
                                loopMode != LoopMode.off;
                        return Semantics(
                          label: 'Next track',
                          child: IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: canSkipNext
                                  ? Colors.white
                                  : const Color(0xFF424242),
                            ),
                            iconSize: 28,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed:
                                canSkipNext ? () => handler.skipToNext() : null,
                          ),
                        );
                      },
                    ),

                    // Repeat button — cycles off → one → all → off
                    StreamBuilder<LoopMode>(
                      stream: handler.player.loopModeStream,
                      builder: (context, snapshot) {
                        final loopMode = snapshot.data ?? LoopMode.off;
                        IconData icon;
                        Color color;
                        String semanticLabel;
                        AudioServiceRepeatMode nextMode;

                        switch (loopMode) {
                          case LoopMode.off:
                            icon = Icons.repeat;
                            color = Colors.white;
                            semanticLabel = 'Repeat off';
                            nextMode = AudioServiceRepeatMode.one;
                            break;
                          case LoopMode.one:
                            icon = Icons.repeat_one;
                            color = const Color(0xFF1DB954);
                            semanticLabel = 'Repeat one';
                            nextMode = AudioServiceRepeatMode.all;
                            break;
                          case LoopMode.all:
                            icon = Icons.repeat;
                            color = const Color(0xFF1DB954);
                            semanticLabel = 'Repeat all';
                            nextMode = AudioServiceRepeatMode.none;
                            break;
                        }

                        return Semantics(
                          label: semanticLabel,
                          child: IconButton(
                            icon: Icon(icon, color: color),
                            iconSize: 28,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: () => handler.setRepeatMode(nextMode),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 7. Secondary controls row — playlist + download on left, queue on right
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side: Add to Playlist + Download
                    Row(
                      children: [
                        // Add to Playlist button
                        Semantics(
                          label: 'Add to playlist',
                          child: IconButton(
                            icon: const Icon(
                              Icons.playlist_add,
                              color: Color(0xFF9E9E9E),
                            ),
                            iconSize: 28,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            onPressed: track != null
                                ? () => PlaylistPickerSheet.show(
                                    context, ref, track)
                                : null,
                            tooltip: 'Add to playlist',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Download button — 3 states
                        _DownloadButton(track: track),
                      ],
                    ),
                    // Right side: Queue button (existing)
                    Semantics(
                      label: 'View queue',
                      child: IconButton(
                        icon: const Icon(
                          Icons.queue_music,
                          color: Colors.white,
                        ),
                        iconSize: 28,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: () => _openQueueSheet(context),
                        tooltip: 'View queue',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openQueueSheet(BuildContext context) {
    QueueBottomSheet.show(context);
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// 300x300dp album art fallback: source-colored container with music_note icon.
class _AlbumArtFallback extends StatelessWidget {
  const _AlbumArtFallback({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: badgeColorFor(source),
      child: const Icon(
        Icons.music_note,
        color: Colors.white70,
        size: 80,
      ),
    );
  }
}

/// Download button for the full player secondary controls.
///
/// Shows three states:
///   - Not downloaded: tappable green download icon, triggers download + SnackBar
///   - Downloading: indeterminate/determinate circular progress indicator
///   - Downloaded: green check circle icon (not tappable)
class _DownloadButton extends ConsumerWidget {
  const _DownloadButton({required this.track});

  final TrackDto? track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (track == null) {
      return IconButton(
        icon: const Icon(Icons.download, color: Color(0xFF424242)),
        iconSize: 28,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: null,
      );
    }
    final trackKey = '${track!.source ?? ''}_${track!.trackId}';
    final entry = ref.watch(
      downloadsProvider.select((map) => map[trackKey]),
    );
    final status = entry?.status ?? DownloadStatus.notDownloaded;
    final progress = entry?.progress ?? 0.0;

    switch (status) {
      case DownloadStatus.notDownloaded:
        return Semantics(
          label: 'Download',
          child: IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF1DB954)),
            iconSize: 28,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: () {
              ref.read(downloadsProvider.notifier).download(track!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Downloading...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  backgroundColor: Color(0xFF1E1E1E),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      case DownloadStatus.downloading:
        return Semantics(
          label: 'Downloading, ${(progress * 100).toInt()}%',
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 2,
                  color: const Color(0xFF1DB954),
                ),
              ),
            ),
          ),
        );
      case DownloadStatus.downloaded:
        return Semantics(
          label: 'Downloaded',
          child: const IconButton(
            icon: Icon(Icons.check_circle, color: Color(0xFF1DB954)),
            iconSize: 28,
            constraints: BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: null,
          ),
        );
    }
  }
}

/// Small chip showing audio format and/or bitrate info.
class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.track});

  final dynamic track;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (track.ext != null) parts.add(track.ext!.toUpperCase());
    if (track.bitrate != null) parts.add('${track.bitrate}k');
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        parts.join(' · '),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}

