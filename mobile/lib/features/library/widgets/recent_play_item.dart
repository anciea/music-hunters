import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/track_dto.dart';

/// A vertical item showing 72x72dp cover art and track name below.
///
/// Used in the Recent Plays horizontal scroll section of the Library tab.
/// Item width: 80dp, 8dp horizontal padding between items.
class RecentPlayItem extends StatelessWidget {
  const RecentPlayItem({super.key, required this.track, required this.onTap});

  final TrackDto track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final songName = track.songName ?? 'Unknown';
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              label: '$songName album art',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: track.coverUrl ?? '',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF424242),
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF424242),
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              songName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
