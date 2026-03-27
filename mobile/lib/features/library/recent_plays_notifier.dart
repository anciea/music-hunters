import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/db/database_provider.dart';
import '../../core/models/recent_play.dart';
import '../../core/models/track_dto.dart';

part 'recent_plays_notifier.g.dart';

/// Manages the recently played tracks list.
///
/// State is [List<RecentPlay>] loaded from SQLite, sorted by most recent first,
/// capped at 200 entries. Each play is stored with a Unix epoch millisecond
/// timestamp.
///
/// Uses INSERT OR REPLACE so replaying the same track moves it to the top
/// without creating duplicates (enforced by the UNIQUE(track_id, source)
/// constraint on the recent_plays table).
@Riverpod(keepAlive: true)
class RecentPlays extends _$RecentPlays {
  @override
  List<RecentPlay> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final db = await ref.read(databaseProvider.future);
    final rows = await db.query('recent_plays',
        orderBy: 'played_at DESC', limit: 200);
    state = rows.map((row) {
      final track = TrackDto.fromJson(
          jsonDecode(row['track_json'] as String) as Map<String, dynamic>);
      return RecentPlay(
        track: track,
        playedAt: row['played_at'] as int,
      );
    }).toList();
  }

  /// Records a play of [track]. Uses INSERT OR REPLACE so replaying the same
  /// track moves it to the top. Trims to 200 entries after insert.
  Future<void> record(TrackDto track) async {
    final db = await ref.read(databaseProvider.future);
    await db.rawInsert(
      'INSERT OR REPLACE INTO recent_plays (track_id, source, track_json, played_at) VALUES (?, ?, ?, ?)',
      [
        track.trackId,
        track.source ?? '',
        jsonEncode(track.toJson()),
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
    // Trim to 200
    await db.rawDelete(
      'DELETE FROM recent_plays WHERE id NOT IN (SELECT id FROM recent_plays ORDER BY played_at DESC LIMIT 200)',
    );
    await _load();
  }

  Future<void> reload() => _load();
}
