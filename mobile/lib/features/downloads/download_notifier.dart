import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/config/app_config.dart';
import '../../core/db/database_provider.dart';
import '../../core/api/dio_provider.dart';
import '../../core/models/download_entry.dart';
import '../../core/models/track_dto.dart';

part 'download_notifier.g.dart';

/// Manages the download state for all tracks.
///
/// State is a map from track key ('source_trackId') to [DownloadEntry].
/// On build, hydrates from the local SQLite database — verifying each file
/// still exists on disk and cleaning up stale rows.
///
/// Enforces a maximum of 3 concurrent downloads.
@Riverpod(keepAlive: true)
class Downloads extends _$Downloads {
  @override
  Map<String, DownloadEntry> build() {
    // Hydrate from DB asynchronously — initial state is empty, filled after DB read
    _hydrate();
    return {};
  }

  Future<void> _hydrate() async {
    final db = await ref.read(databaseProvider.future);
    final rows = await db.query('downloads');
    final map = <String, DownloadEntry>{};
    for (final row in rows) {
      final key = '${row['source']}_${row['track_id']}';
      final localPath = row['local_path'] as String;
      // Verify file still exists on disk
      if (File(localPath).existsSync()) {
        map[key] = DownloadEntry(
          status: DownloadStatus.downloaded,
          progress: 1.0,
          localPath: localPath,
          fileSize: (row['file_size'] as int?) ?? 0,
        );
      } else {
        // File deleted outside app — clean up DB row
        await db.delete('downloads',
            where: 'track_id = ? AND source = ?',
            whereArgs: [row['track_id'], row['source']]);
      }
    }
    state = map;
  }

  /// Returns the download state for a given track key ('source_trackId').
  DownloadEntry statusFor(String trackKey) =>
      state[trackKey] ??
      const DownloadEntry(status: DownloadStatus.notDownloaded);

  /// Starts downloading [track]. Enforces 3 parallel download max.
  /// Does nothing if track is already downloading or downloaded.
  Future<void> download(TrackDto track) async {
    final key = '${track.source ?? ''}_${track.trackId}';
    final existing = statusFor(key);
    if (existing.status == DownloadStatus.downloading ||
        existing.status == DownloadStatus.downloaded) {
      return; // Already in progress or done
    }

    // Enforce 3-parallel limit
    final activeCount = state.values
        .where((e) => e.status == DownloadStatus.downloading)
        .length;
    if (activeCount >= 3) return; // Silently skip — UI can show "queued" later

    // Mark as downloading
    state = {
      ...state,
      key: const DownloadEntry(status: DownloadStatus.downloading),
    };

    try {
      // Determine download directory
      final extDir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final dlDir = Directory(p.join(extDir.path, 'downloads'));
      if (!dlDir.existsSync()) dlDir.createSync(recursive: true);

      final ext = track.ext ?? 'mp3';
      final filePath =
          p.join(dlDir.path, '${track.source ?? ''}_${track.trackId}.$ext');

      final dio = ref.read(dioProvider);
      await dio.download(
        '${AppConfig.apiBaseUrl}/download'
            '?track_id=${Uri.encodeComponent(track.trackId)}'
            '&source=${Uri.encodeComponent(track.source ?? '')}',
        filePath,
        options: Options(headers: {'X-API-Key': AppConfig.apiKey}),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = {
              ...state,
              key: DownloadEntry(
                status: DownloadStatus.downloading,
                progress: received / total,
              ),
            };
          }
        },
      );

      // Get file size
      final file = File(filePath);
      final fileSize = file.existsSync() ? file.lengthSync() : 0;

      // Save to DB
      final db = await ref.read(databaseProvider.future);
      await db.insert('downloads', {
        'track_id': track.trackId,
        'source': track.source ?? '',
        'local_path': filePath,
        'track_json': jsonEncode(track.toJson()),
        'file_size': fileSize,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      state = {
        ...state,
        key: DownloadEntry(
          status: DownloadStatus.downloaded,
          progress: 1.0,
          localPath: filePath,
          fileSize: fileSize,
        ),
      };
    } catch (e) {
      // On failure, revert to notDownloaded
      state = {
        ...state,
        key: const DownloadEntry(status: DownloadStatus.notDownloaded),
      };
    }
  }

  /// Deletes a downloaded track: removes DB row, deletes file, updates state.
  Future<void> delete(TrackDto track) async {
    final key = '${track.source ?? ''}_${track.trackId}';
    final entry = statusFor(key);
    if (entry.localPath != null) {
      final file = File(entry.localPath!);
      if (file.existsSync()) file.deleteSync();
    }
    final db = await ref.read(databaseProvider.future);
    await db.delete('downloads',
        where: 'track_id = ? AND source = ?',
        whereArgs: [track.trackId, track.source ?? '']);
    final newState = Map<String, DownloadEntry>.from(state);
    newState.remove(key);
    state = newState;
  }

  /// Returns all downloaded tracks as TrackDto list (for Downloads section in Library).
  Future<List<TrackDto>> allDownloads() async {
    final db = await ref.read(databaseProvider.future);
    final rows = await db.query('downloads', orderBy: 'downloaded_at DESC');
    return rows.map((row) {
      return TrackDto.fromJson(
          jsonDecode(row['track_json'] as String) as Map<String, dynamic>);
    }).toList();
  }
}
