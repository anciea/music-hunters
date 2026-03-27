import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/track_dto.dart';

/// A download tile for a locally stored track.
///
/// Shows album art, track name, artist, file size and "Offline" badge.
/// Trailing "more" icon opens a bottom sheet with "Play Now" and "Delete".
class DownloadTile extends StatelessWidget {
  const DownloadTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.onDelete,
  });

  final TrackDto track;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
              color: const Color(0xFF424242),
              child: const Icon(Icons.music_note, color: Colors.white54),
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
                color: Color(0xFF9E9E9E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text(
                  track.fileSize ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          iconSize: 24,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          onPressed: () => _showOptionsSheet(context),
        ),
        onTap: onTap,
        isThreeLine: true,
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow, color: Color(0xFF9E9E9E)),
            title: const Text(
              'Play Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            minTileHeight: 56,
            onTap: () {
              Navigator.of(ctx).pop();
              onTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Color(0xFF9E9E9E)),
            title: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            minTileHeight: 56,
            onTap: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
