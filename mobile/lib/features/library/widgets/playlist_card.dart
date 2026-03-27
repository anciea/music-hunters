import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/playlist_model.dart';

/// A 2-column grid card for a playlist.
///
/// Shows a cover mosaic (up to 4 track cover images in 2x2 grid),
/// playlist name, and track count. Tap navigates to playlist detail;
/// long-press shows context menu.
class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.onLongPress,
  });

  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${playlist.name}, ${playlist.trackCount} tracks',
      child: Card(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover mosaic
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: _buildMosaic(),
                ),
              ),
              // Playlist name
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: Text(
                  playlist.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Track count
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 4, bottom: 8),
                child: Text(
                  '${playlist.trackCount} tracks',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMosaic() {
    final urls = playlist.coverUrls;

    if (urls.isEmpty) {
      // No tracks — single placeholder
      return Container(
        color: const Color(0xFF424242),
        child: const Center(
          child: Icon(Icons.music_note, size: 40, color: Colors.white54),
        ),
      );
    }

    if (urls.length < 4) {
      // 1–3 URLs: show first URL if available, fill rest with placeholder
      return LayoutBuilder(
        builder: (context, constraints) {
          final half = constraints.maxWidth / 2;
          return GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: List.generate(4, (i) {
              final url = i < urls.length ? urls[i] : null;
              return _quadrant(url, half);
            }),
          );
        },
      );
    }

    // 4+ URLs: 2x2 grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final half = constraints.maxWidth / 2;
        return GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: List.generate(4, (i) {
            return _quadrant(urls[i], half);
          }),
        );
      },
    );
  }

  Widget _quadrant(String? url, double size) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFF424242),
        child: const Center(
          child: Icon(Icons.music_note, size: 24, color: Colors.white54),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: size,
        height: size,
        color: const Color(0xFF424242),
        child: const Icon(Icons.music_note, size: 24, color: Colors.white54),
      ),
      errorWidget: (context, url, error) => Container(
        width: size,
        height: size,
        color: const Color(0xFF424242),
        child: const Icon(Icons.music_note, size: 24, color: Colors.white54),
      ),
    );
  }
}
