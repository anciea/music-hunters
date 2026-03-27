import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/track_dto.dart';
import '../playlist_notifier.dart';
import 'playlist_name_dialog.dart';

/// Bottom sheet that lets the user pick a playlist to add a track to.
///
/// Shows all existing playlists plus a "New playlist" option at the top.
/// Adding a track dismisses the sheet and shows a confirmation SnackBar.
class PlaylistPickerSheet extends StatelessWidget {
  const PlaylistPickerSheet({
    super.key,
    required this.ref,
    required this.track,
  });

  final WidgetRef ref;
  final TrackDto track;

  /// Shows the picker sheet modally.
  static Future<void> show(
      BuildContext context, WidgetRef ref, TrackDto track) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => Semantics(
        container: true,
        label: 'Add to playlist',
        child: PlaylistPickerSheet(ref: ref, track: track),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.read(playlistsProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Add to playlist',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // "New playlist" option
          ListTile(
            leading: const Icon(Icons.add, color: Color(0xFF1DB954)),
            title: const Text(
              'New playlist',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1DB954),
              ),
            ),
            minTileHeight: 56,
            onTap: () async {
              Navigator.of(context).pop();
              final name = await PlaylistNameDialog.show(
                context,
                title: 'New Playlist',
                confirmLabel: 'Create Playlist',
              );
              if (name != null && name.isNotEmpty) {
                final newId =
                    await ref.read(playlistsProvider.notifier).create(name);
                await ref
                    .read(playlistsProvider.notifier)
                    .addTrack(newId, track);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added to $name',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: const Color(0xFF1E1E1E),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          // Existing playlists
          if (playlists.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlists.length,
              itemBuilder: (ctx, index) {
                final playlist = playlists[index];
                final firstUrl =
                    playlist.coverUrls.isNotEmpty ? playlist.coverUrls.first : null;

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: firstUrl != null && firstUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: firstUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _playlistThumbPlaceholder(),
                            errorWidget: (_, __, ___) =>
                                _playlistThumbPlaceholder(),
                          )
                        : _playlistThumbPlaceholder(),
                  ),
                  title: Text(
                    playlist.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${playlist.trackCount} tracks',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  minTileHeight: 56,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref
                        .read(playlistsProvider.notifier)
                        .addTrack(playlist.id, track);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added to ${playlist.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: const Color(0xFF1E1E1E),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _playlistThumbPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      color: const Color(0xFF424242),
      child:
          const Icon(Icons.music_note, size: 20, color: Colors.white54),
    );
  }
}
