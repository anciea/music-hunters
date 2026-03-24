import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/queue_notifier.dart';
import '../../core/models/track_dto.dart';
import '../downloads/download_notifier.dart';
import 'dialogs/playlist_name_dialog.dart';
import 'playlist_notifier.dart';
import 'recent_plays_notifier.dart';
import 'widgets/download_tile.dart';
import 'widgets/playlist_card.dart';
import 'widgets/recent_play_item.dart';

/// The Library tab — the central hub for the user's music collection.
///
/// Renders three sections in a single [CustomScrollView]:
/// 1. Recent Plays — horizontal scroll of the last 10 played tracks
/// 2. Playlists — 2-column grid of user-created playlists
/// 3. Downloads — list of locally stored tracks
///
/// A FAB at bottom-right opens the New Playlist name dialog.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  List<TrackDto> _downloads = [];

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final tracks =
        await ref.read(downloadsProvider.notifier).allDownloads();
    if (mounted) {
      setState(() => _downloads = tracks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentPlays = ref.watch(recentPlaysProvider);
    final playlists = ref.watch(playlistsProvider);

    // Refresh downloads when downloadsProvider state changes
    ref.listen(downloadsProvider, (_, __) => _loadDownloads());

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewPlaylistDialog(context),
        backgroundColor: const Color(0xFF1E1E1E),
        tooltip: 'Create playlist',
        child: const Icon(Icons.add, color: Color(0xFF1DB954)),
      ),
      body: CustomScrollView(
        slivers: [
          // AppBar
          const SliverAppBar(
            title: Text('Library'),
            backgroundColor: Color(0xFF121212),
            floating: false,
            pinned: true,
          ),

          // --- Recent Plays section ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'Recent Plays',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 108,
              child: recentPlays.isEmpty
                  ? const Center(
                      child: Text(
                        'Play something to see it here',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: recentPlays.take(10).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = recentPlays[index];
                        return RecentPlayItem(
                          track: item.track,
                          onTap: () => ref
                              .read(queueProvider.notifier)
                              .playNow(item.track),
                        );
                      },
                    ),
            ),
          ),

          // --- Playlists section ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'Playlists',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (playlists.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.queue_music, size: 64, color: Color(0xFF424242)),
                    SizedBox(height: 16),
                    Text(
                      'No playlists yet',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to create your first playlist.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final playlist = playlists[index];
                    return PlaylistCard(
                      playlist: playlist,
                      onTap: () =>
                          context.push('/library/playlist/${playlist.id}'),
                      onLongPress: () =>
                          _showPlaylistContextMenu(context, playlist.id,
                              playlist.name),
                    );
                  },
                  childCount: playlists.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
              ),
            ),

          // --- Downloads section ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: Text(
                'Downloads',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_downloads.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.download, size: 64, color: Color(0xFF424242)),
                    SizedBox(height: 16),
                    Text(
                      'No downloads yet',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the download icon on any track to save it offline.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9E9E9E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _downloads[index];
                  return DownloadTile(
                    track: track,
                    onTap: () =>
                        ref.read(queueProvider.notifier).playNow(track),
                    onDelete: () =>
                        ref.read(downloadsProvider.notifier).delete(track),
                  );
                },
                childCount: _downloads.length,
              ),
            ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _showNewPlaylistDialog(BuildContext context) async {
    final name = await PlaylistNameDialog.show(
      context,
      title: 'New Playlist',
      confirmLabel: 'Create Playlist',
    );
    if (name != null && name.isNotEmpty && mounted) {
      await ref.read(playlistsProvider.notifier).create(name);
    }
  }

  void _showPlaylistContextMenu(
      BuildContext context, int playlistId, String playlistName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading:
                const Icon(Icons.edit, color: Color(0xFF9E9E9E)),
            title: const Text(
              'Rename',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            minTileHeight: 56,
            onTap: () async {
              Navigator.of(ctx).pop();
              final newName = await PlaylistNameDialog.show(
                context,
                title: 'Rename Playlist',
                initialName: playlistName,
                confirmLabel: 'Rename',
              );
              if (newName != null && newName.isNotEmpty && mounted) {
                await ref
                    .read(playlistsProvider.notifier)
                    .rename(playlistId, newName);
              }
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.delete, color: Color(0xFF9E9E9E)),
            title: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            minTileHeight: 56,
            onTap: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(playlistsProvider.notifier)
                  .delete(playlistId);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
