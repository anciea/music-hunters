import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/download_entry.dart';
import '../../../core/models/track_dto.dart';
import '../../../features/downloads/download_notifier.dart';
import 'source_badge.dart';

/// A compact list tile for a single search result.
///
/// Shows: 48x48 album art thumbnail with download state overlay, track title,
/// artist, duration, source badge.
/// Tap triggers [onTap] callback — wired to playback in Plan 02-03.
/// Long-press triggers [onLongPress] callback — opens context menu in Plan 03-03.
///
/// The album art overlay has three states (per UI-SPEC):
///   - Not downloaded: tappable download icon (green)
///   - Downloading: circular progress indicator (green)
///   - Downloaded: check circle icon (green)
class TrackListTile extends ConsumerWidget {
  const TrackListTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onLongPress,
  });

  final TrackDto track;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackKey = '${track.source ?? ''}_${track.trackId}';
    final entry = ref.watch(
      downloadsProvider.select((map) => map[trackKey]),
    );
    final status = entry?.status ?? DownloadStatus.notDownloaded;
    final progress = entry?.progress ?? 0.0;

    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        leading: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: track.coverUrl ?? '',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF424242),
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 48,
                    height: 48,
                    color: badgeColorFor(track.source ?? ''),
                    child: const Icon(Icons.music_note, color: Colors.white70),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildDownloadOverlay(ref, status, progress, trackKey),
              ),
            ],
          ),
        ),
        title: Text(
          track.songName ?? 'Unknown',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.singers ?? 'Unknown artist',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text(
                  track.duration ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                SourceBadge(source: track.source ?? ''),
              ],
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget _buildDownloadOverlay(
    WidgetRef ref,
    DownloadStatus status,
    double progress,
    String trackKey,
  ) {
    switch (status) {
      case DownloadStatus.notDownloaded:
        return GestureDetector(
          onTap: () => ref.read(downloadsProvider.notifier).download(track),
          child: Semantics(
            label: 'Download',
            child: const Icon(
              Icons.download,
              size: 24,
              color: Color(0xFF1DB954),
            ),
          ),
        );
      case DownloadStatus.downloading:
        return Semantics(
          label: 'Downloading, ${(progress * 100).toInt()}%',
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2,
              color: const Color(0xFF1DB954),
            ),
          ),
        );
      case DownloadStatus.downloaded:
        return Semantics(
          label: 'Downloaded',
          child: const Icon(
            Icons.check_circle,
            size: 24,
            color: Color(0xFF1DB954),
          ),
        );
    }
  }
}
