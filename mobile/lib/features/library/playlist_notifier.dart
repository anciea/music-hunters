import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/db/database_provider.dart';
import '../../core/models/playlist_model.dart';
import '../../core/models/track_dto.dart';

part 'playlist_notifier.g.dart';

/// Manages the list of user-created playlists and their tracks.
///
/// State is [List<PlaylistModel>] loaded from SQLite, including aggregated
/// track counts and up to 4 cover URLs per playlist.
///
/// All mutations reload state from the database immediately for consistency.
@Riverpod(keepAlive: true)
class Playlists extends _$Playlists {
  @override
  List<PlaylistModel> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final db = await ref.read(databaseProvider.future);
    final rows = await db.rawQuery('''
      SELECT p.id, p.name, p.created_at,
        (SELECT COUNT(*) FROM playlist_tracks pt WHERE pt.playlist_id = p.id) AS track_count,
        (SELECT GROUP_CONCAT(json_extract(pt2.track_json, '\$.cover_url'), '|||')
         FROM (SELECT track_json FROM playlist_tracks pt2 WHERE pt2.playlist_id = p.id ORDER BY pt2.position ASC LIMIT 4) pt2
        ) AS cover_urls_raw
      FROM playlists p
      ORDER BY p.created_at DESC
    ''');
    state = rows.map((row) {
      final coverUrlsRaw = row['cover_urls_raw'] as String?;
      final coverUrls = coverUrlsRaw != null && coverUrlsRaw.isNotEmpty
          ? coverUrlsRaw
              .split('|||')
              .map((u) => u == 'null' ? null : u)
              .toList()
          : <String?>[];
      return PlaylistModel(
        id: row['id'] as int,
        name: row['name'] as String,
        createdAt: row['created_at'] as int,
        trackCount: row['track_count'] as int,
        coverUrls: coverUrls,
      );
    }).toList();
  }

  Future<void> reload() => _load();

  /// Creates a new playlist with [name] and returns its new database id.
  Future<int> create(String name) async {
    final db = await ref.read(databaseProvider.future);
    final id = await db.insert('playlists', {
      'name': name.trim(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    await _load();
    return id;
  }

  /// Renames playlist with [id] to [newName].
  Future<void> rename(int id, String newName) async {
    final db = await ref.read(databaseProvider.future);
    await db.update('playlists', {'name': newName.trim()},
        where: 'id = ?', whereArgs: [id]);
    await _load();
  }

  /// Deletes playlist with [id]. CASCADE delete handles playlist_tracks rows.
  Future<void> delete(int id) async {
    final db = await ref.read(databaseProvider.future);
    await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
    // CASCADE delete handles playlist_tracks rows
    await _load();
  }

  /// Appends [track] to the playlist with [playlistId].
  Future<void> addTrack(int playlistId, TrackDto track) async {
    final db = await ref.read(databaseProvider.future);
    // Get next position
    final maxPos = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT MAX(position) FROM playlist_tracks WHERE playlist_id = ?',
          [playlistId])) ??
        -1;
    await db.insert('playlist_tracks', {
      'playlist_id': playlistId,
      'track_id': track.trackId,
      'source': track.source ?? '',
      'track_json': jsonEncode(track.toJson()),
      'position': maxPos + 1,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    });
    await _load(); // Refresh to update track counts and cover URLs
  }

  /// Returns all tracks in playlist [playlistId] ordered by position.
  Future<List<TrackDto>> tracksForPlaylist(int playlistId) async {
    final db = await ref.read(databaseProvider.future);
    final rows = await db.query('playlist_tracks',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
        orderBy: 'position ASC');
    return rows.map((row) {
      return TrackDto.fromJson(
          jsonDecode(row['track_json'] as String) as Map<String, dynamic>);
    }).toList();
  }

  /// Removes [track] from playlist [playlistId] and renumbers remaining positions.
  Future<void> removeTrack(int playlistId, TrackDto track) async {
    final db = await ref.read(databaseProvider.future);
    await db.delete('playlist_tracks',
        where: 'playlist_id = ? AND track_id = ? AND source = ?',
        whereArgs: [playlistId, track.trackId, track.source ?? '']);
    // Renumber positions
    final remaining = await db.query('playlist_tracks',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
        orderBy: 'position ASC');
    final batch = db.batch();
    for (var i = 0; i < remaining.length; i++) {
      batch.update('playlist_tracks', {'position': i},
          where: 'id = ?', whereArgs: [remaining[i]['id']]);
    }
    await batch.commit(noResult: true);
    await _load();
  }

  /// Moves a track from [oldIndex] to [newIndex] within playlist [playlistId].
  ///
  /// Uses the same index adjustment as Flutter's [ReorderableListView] —
  /// when moving downward, the reported new index is one higher than expected.
  Future<void> reorderTrack(
      int playlistId, int oldIndex, int newIndex) async {
    final db = await ref.read(databaseProvider.future);

    // Fetch current rows in position order — each row has DB 'id'
    final rows = await db.query('playlist_tracks',
        where: 'playlist_id = ?',
        whereArgs: [playlistId],
        orderBy: 'position ASC');

    // Reorder the rows list using the same adjustment Flutter's ReorderableListView uses
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final reordered = List<Map<String, Object?>>.from(rows);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(adjusted, item);

    // Batch update: iterate the REORDERED list so position i maps to the correct DB row id
    final batch = db.batch();
    for (var i = 0; i < reordered.length; i++) {
      batch.update('playlist_tracks', {'position': i},
          where: 'id = ?', whereArgs: [reordered[i]['id']]);
    }
    await batch.commit(noResult: true);
  }
}
