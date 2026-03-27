import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/track_dto.dart';
import 'source_badge.dart';

/// A compact list tile for a single search result.
///
/// Shows: 48x48 album art thumbnail, track title, artist, duration, source badge.
/// Tap triggers [onTap] callback — wired to playback in Plan 02-03.
/// Long-press triggers [onLongPress] callback — opens context menu in Plan 03-03.
class TrackListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      child: ListTile(
        leading: ClipRRect(
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
}
