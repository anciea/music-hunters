import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/queue_notifier.dart';
import '../../core/models/track_dto.dart';
import '../search/widgets/source_badge.dart';
import 'playlist_notifier.dart';

/// Screen for viewing and managing tracks within a single playlist.
///
/// Route: `/library/playlist/:id`
///
/// Features:
/// - Reorderable track list with drag handles
/// - Swipe-to-delete for removing individual tracks
/// - AppBar delete button with confirmation dialog
/// - Empty state with instructions
class PlaylistDetailScreen extends ConsumerStatefulWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final int playlistId;

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState
    extends ConsumerState<PlaylistDetailScreen> {
  List<TrackDto> _tracks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final tracks = await ref
        .read(playlistsProvider.notifier)
        .tracksForPlaylist(widget.playlistId);
    if (mounted) {
      setState(() {
        _tracks = tracks;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);
    final playlist =
        playlists.where((p) => p.id == widget.playlistId).firstOrNull;
    final playlistName = playlist?.name ?? 'Playlist';
    final trackCount = _tracks.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playlistName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '$trackCount tracks',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Delete playlist',
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: const Color(0xFF9E9E9E),
              iconSize: 24,
              constraints:
                  const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: () => _showDeleteDialog(context, playlistName),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _tracks.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    final key = ValueKey(
                        '${track.source ?? ''}_${track.trackId}_$index');
                    return _buildTrackItem(context, track, index, key);
                  },
                ),
    );
  }

  Widget _buildTrackItem(
      BuildContext context, TrackDto track, int index, Key key) {
    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFE53935),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (_) async {
        final removed = _tracks[index];
        setState(() => _tracks.removeAt(index));
        await ref
            .read(playlistsProvider.notifier)
            .removeTrack(widget.playlistId, removed);
      },
      child: Card(
        key: ValueKey('card_${track.source ?? ''}_${track.trackId}_$index'),
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        child: ListTile(
          leading: _buildAlbumArt(track),
          title: Text(
            track.songName ?? 'Unknown',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
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
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(width: 8),
                  SourceBadge(source: track.source ?? ''),
                ],
              ),
            ],
          ),
          trailing: ReorderableDragStartListener(
            index: index,
            child: Semantics(
              label: 'Drag to reorder',
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.drag_handle,
                    color: Color(0xFF424242)),
              ),
            ),
          ),
          onTap: () =>
              ref.read(queueProvider.notifier).playNow(track),
          isThreeLine: true,
        ),
      ),
    );
  }

  Widget _buildAlbumArt(TrackDto track) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 48,
        height: 48,
        child: track.coverUrl != null && track.coverUrl!.isNotEmpty
            ? Image.network(
                track.coverUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _albumArtPlaceholder(track),
              )
            : _albumArtPlaceholder(track),
      ),
    );
  }

  Widget _albumArtPlaceholder(TrackDto track) {
    return Container(
      width: 48,
      height: 48,
      color: badgeColorFor(track.source ?? ''),
      child: const Icon(Icons.music_note,
          color: Colors.white70),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 64, color: Color(0xFF424242)),
          SizedBox(height: 16),
          Text(
            'This playlist is empty',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Long-press a search result to add songs.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      final adjusted =
          newIndex > oldIndex ? newIndex - 1 : newIndex;
      final item = _tracks.removeAt(oldIndex);
      _tracks.insert(adjusted, item);
    });
    await ref
        .read(playlistsProvider.notifier)
        .reorderTrack(widget.playlistId, oldIndex, newIndex);
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String playlistName) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete playlist?',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        content: Text(
          '"$playlistName" will be permanently deleted.',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9E9E9E),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Keep playlist',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(playlistsProvider.notifier)
          .delete(widget.playlistId);
      if (mounted) nav.pop();
    }
  }
}
