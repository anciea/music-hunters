import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'database_provider.g.dart';

/// Provides a singleton [Database] instance that opens (or creates) the local
/// SQLite database on first access.
///
/// Kept alive for the lifetime of the app so database connection overhead is
/// paid only once.
@Riverpod(keepAlive: true)
Future<Database> database(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = p.join(dir.path, 'musicdl.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE playlists (
          id         INTEGER PRIMARY KEY AUTOINCREMENT,
          name       TEXT    NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE playlist_tracks (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
          track_id    TEXT    NOT NULL,
          source      TEXT    NOT NULL,
          track_json  TEXT    NOT NULL,
          position    INTEGER NOT NULL,
          added_at    INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE recent_plays (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          track_id    TEXT    NOT NULL,
          source      TEXT    NOT NULL,
          track_json  TEXT    NOT NULL,
          played_at   INTEGER NOT NULL,
          UNIQUE(track_id, source)
        )
      ''');
      await db.execute('''
        CREATE TABLE downloads (
          track_id      TEXT    NOT NULL,
          source        TEXT    NOT NULL,
          local_path    TEXT    NOT NULL,
          track_json    TEXT    NOT NULL,
          file_size     INTEGER NOT NULL DEFAULT 0,
          downloaded_at INTEGER NOT NULL,
          PRIMARY KEY (track_id, source)
        )
      ''');
      // Enable foreign keys for CASCADE deletes
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onOpen: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
  );
}
