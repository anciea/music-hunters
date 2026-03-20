# Phase 4: Library - Research

**Researched:** 2026-03-27
**Domain:** Flutter SQLite persistence, file download, playlist/recent-plays CRUD, Riverpod state
**Confidence:** HIGH

## Summary

Phase 4 completes the Library tab by adding three features that share a single SQLite database: track downloads (with per-track download state), persistent playlists (full CRUD + reorder), and automatic recent-plays recording. All three domains are well-understood Flutter patterns using sqflite 2.4.2 (already resolved in the project's pub cache) alongside path_provider 2.1.5 and the `path` utility package.

The main technical challenge is **download state** — it must be observable from multiple widget trees simultaneously (TrackListTile in Search, TrackListTile in Playlist Detail, the full player secondary controls row, and the Downloads section). A `keepAlive: true` Riverpod notifier backed by a Map<trackKey, DownloadState> provides a single source of truth that all widgets can watch cheaply.

The secondary challenge is **playing from local file** — `QueueNotifier._toAudioSource` currently builds a `/stream` URI. When a downloaded track is played, the URI must be `Uri.file(localPath)` instead, with no `X-API-Key` header. The integration point is `QueueNotifier.playNow` (and `addToQueue` / `playNext`), which should check the downloads DB before constructing the AudioSource.

**Primary recommendation:** Build the SQLite schema first (Wave 0), then download-state infrastructure, then playlist CRUD, then recent-plays — each wave is independent once the DB layer exists.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Download Storage & UX**
- App-specific external storage (`getExternalStorageDirectory`) — no permissions needed, survives app data clear
- Circular progress on the download button itself — compact, no extra UI real estate
- Auto-play from local file when tapping a downloaded track in search with subtle "offline" badge — seamless experience
- 3 parallel downloads maximum — balances speed with bandwidth

**Playlist UI & Interaction**
- FAB (+) on Library tab to name dialog to empty playlist created — minimal friction
- Long-press context menu adds "Add to Playlist" option to playlist picker bottom sheet — extends existing Phase 3 pattern
- Card grid (2 columns) with cover art mosaic from first 4 tracks — visually rich, standard music app pattern
- AlertDialog with playlist name for delete confirmation — simple, standard Android

**Recent Plays & Library Tab Organization**
- 200 recent play entries max — covers ~2 weeks of listening, keeps DB small
- Horizontal scroll of recent 10 at top of Library tab + full list view below — quick access + browsing
- Three sections on Library tab: "Recent Plays" (top), "Playlists" (middle), "Downloads" (bottom) — single scrollable view
- Move to top on replay (no duplicates in recent plays) — cleaner list, always shows latest

### Claude's Discretion

No "You decide" answers — all questions resolved with recommended defaults.

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DL-01 | User can download a track to local storage from search results or player | `path_provider.getExternalStorageDirectory` + sqflite `downloads` table + Dio download-to-file; DownloadNotifier tracks state |
| DL-02 | Downloaded tracks show download status indicator (not downloaded / downloading / downloaded) | `keepAlive` DownloadNotifier with `Map<trackKey, DownloadEntry>` observable by any widget |
| DL-03 | User can browse a downloads library screen showing all locally stored tracks | SliverList in Library tab reading `downloads` table; existing file check on load |
| DL-04 | Downloaded tracks play from local file without network | `QueueNotifier._toAudioSource` checks DownloadNotifier; uses `AudioSource.uri(Uri.file(...))` when local path exists |
| PLIST-01 | User can create a named playlist | `playlists` table + `PlaylistNotifier.create(name)` + FAB + AlertDialog |
| PLIST-02 | User can add a song to a playlist from search results or player | `playlist_tracks` table + extended long-press menu + playlist picker bottom sheet |
| PLIST-03 | User can remove a song from a playlist | Dismissible swipe-to-delete in Playlist Detail screen + `PlaylistNotifier.removeTrack` |
| PLIST-04 | User can view playlist contents with track list | Playlist Detail route `/library/playlist/:id` + `PlaylistTracksNotifier` |
| PLIST-05 | User can delete a playlist (with confirmation) | AlertDialog + `PlaylistNotifier.delete(id)` cascades to `playlist_tracks` |
| PLIST-06 | User can reorder tracks within a playlist | `ReorderableListView` + `position` column in `playlist_tracks` + `PlaylistTracksNotifier.reorder` |
| REC-01 | App records recently played tracks automatically | Hook in `QueueNotifier.playNow` calling `RecentPlaysNotifier.record(track)` |
| REC-02 | User can view recent plays list and tap to replay | Horizontal scroll (10 items) + `QueueNotifier.playNow` on tap; `RecentPlaysNotifier` loads from `recent_plays` table |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| sqflite | 2.4.2 (verified in pub cache) | SQLite database for playlists, recent plays, download metadata | Flutter's official SQLite binding; already resolved in project |
| path_provider | 2.1.5 (pub.dev) | `getExternalStorageDirectory()` for download file path | Locked decision; standard Flutter storage API |
| path | 1.9.x (transitive via flutter) | `p.join()`, `p.extension()` path construction | Standard utility; avoids manual string concatenation |
| dio | 5.9.2 (existing) | Download audio file via HTTP to local path | Already in project; `dio.download()` streams bytes to file |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_riverpod | 3.3.1 (existing) | `DownloadNotifier`, `PlaylistNotifier`, `RecentPlaysNotifier` | Already established in project |
| freezed_annotation | 3.1.0 (existing) | Immutable models for `PlaylistModel`, `DownloadEntry` | All models in project use Freezed |

### New packages to add to pubspec.yaml
```yaml
dependencies:
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  path: ^1.9.0
```

**Installation:**
```bash
flutter pub add sqflite path_provider path
flutter pub get
```

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| sqflite | drift (formerly moor) | Drift has type-safe query builder but adds code-gen complexity; sqflite is simpler for this schema |
| sqflite | hive / isar | Hive is document-store (no relational joins); playlist_tracks needs JOIN on playlists; sqflite better fit |
| Dio download | http package download | Dio is already in project and supports `onReceiveProgress` for download progress |

---

## Architecture Patterns

### Recommended Project Structure

```
lib/
├── core/
│   ├── db/
│   │   ├── database_provider.dart   # singleton sqflite DB, schema creation
│   │   └── database_provider.g.dart
│   ├── audio/
│   │   └── queue_notifier.dart      # MODIFIED: check downloads before building AudioSource
│   └── models/
│       ├── playlist_model.dart      # Freezed: PlaylistModel
│       ├── download_entry.dart      # Freezed: DownloadEntry (trackKey, localPath, state, progress)
│       └── recent_play.dart         # Freezed: RecentPlay (trackKey + TrackDto snapshot)
├── features/
│   ├── library/
│   │   ├── library_screen.dart      # REPLACED: CustomScrollView with 3 sections
│   │   ├── playlist_notifier.dart   # Riverpod: playlists CRUD
│   │   ├── playlist_notifier.g.dart
│   │   ├── playlist_tracks_notifier.dart    # Riverpod: tracks for one playlist
│   │   ├── playlist_tracks_notifier.g.dart
│   │   ├── recent_plays_notifier.dart       # Riverpod: recent 10 + 200 max
│   │   ├── recent_plays_notifier.g.dart
│   │   └── widgets/
│   │       ├── playlist_card.dart           # 2-col grid card with cover mosaic
│   │       ├── recent_play_item.dart        # 72x72 horizontal scroll item
│   │       └── download_tile.dart           # SliverList tile for downloads section
│   ├── playlist_detail/
│   │   ├── playlist_detail_screen.dart      # ReorderableListView + swipe-dismiss
│   │   └── playlist_detail_notifier.dart    # (may reuse playlist_tracks_notifier)
│   ├── downloads/
│   │   ├── download_notifier.dart           # keepAlive: download state map
│   │   └── download_notifier.g.dart
│   └── search/
│       └── widgets/
│           └── track_list_tile.dart         # MODIFIED: download overlay + "offline" badge
```

### Pattern 1: SQLite singleton via Riverpod

Open the database once per app session via a `keepAlive: true` provider. Schema migrations use sqflite's `onUpgrade` callback with version numbers.

```dart
// Source: sqflite pub.dev docs + established Riverpod pattern in this project
@Riverpod(keepAlive: true)
Future<Database> database(Ref ref) async {
  final dir = await getApplicationDocumentsDirectory(); // fallback; ext storage for files
  final path = p.join(dir.path, 'musicdl.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE playlists (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          name     TEXT    NOT NULL,
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
          track_id    TEXT    NOT NULL,
          source      TEXT    NOT NULL,
          local_path  TEXT    NOT NULL,
          track_json  TEXT    NOT NULL,
          downloaded_at INTEGER NOT NULL,
          PRIMARY KEY (track_id, source)
        )
      ''');
    },
  );
}
```

**Key design notes:**
- `track_json` stores the full `TrackDto` as JSON string — avoids joins to reconstruct display data
- `(track_id, source)` composite primary key matches the project-wide decision (from STATE.md)
- `playlist_tracks.position` is integer that stores sort order; renumber on reorder
- `recent_plays` has `UNIQUE(track_id, source)` + `ON CONFLICT REPLACE` for "move to top" behavior

### Pattern 2: DownloadNotifier — observable per-track state

```dart
// Source: Riverpod docs + this project's @Riverpod(keepAlive: true) pattern
enum DownloadStatus { notDownloaded, downloading, downloaded }

@freezed
abstract class DownloadEntry with _$DownloadEntry {
  const factory DownloadEntry({
    required DownloadStatus status,
    double? progress,      // 0.0–1.0 while downloading
    String? localPath,     // set when downloaded
  }) = _DownloadEntry;
}

@Riverpod(keepAlive: true)
class Downloads extends _$Downloads {
  @override
  Map<String, DownloadEntry> build() => {};

  // trackKey = '${source}_${trackId}'
  DownloadEntry statusFor(String trackKey) =>
      state[trackKey] ?? const DownloadEntry(status: DownloadStatus.notDownloaded);

  Future<void> download(TrackDto track) async { ... }
}
```

Widgets call `ref.watch(downloadsProvider).statusFor(trackKey)` — rebuilds only on that key's state change via `copyWith`.

### Pattern 3: Local file playback in QueueNotifier

Modify `_toAudioSource` to check `DownloadNotifier` before building the stream URI:

```dart
AudioSource _toAudioSource(TrackDto track) {
  final key = '${track.source}_${track.trackId}';
  final entry = ref.read(downloadsProvider).statusFor(key);
  if (entry.status == DownloadStatus.downloaded && entry.localPath != null) {
    return AudioSource.uri(
      Uri.file(entry.localPath!),
      tag: _mediaItemFor(track),
    );
  }
  // existing stream URL logic
  return AudioSource.uri(
    Uri.parse('${AppConfig.apiBaseUrl}/stream?track_id=...'),
    headers: {'X-API-Key': AppConfig.apiKey},
    tag: _mediaItemFor(track),
  );
}
```

### Pattern 4: Recent plays recording hook

Hook into `QueueNotifier.playNow` — the single entry point for playback:

```dart
Future<void> playNow(TrackDto track) async {
  // ... existing playback code ...
  // After playback starts:
  ref.read(recentPlaysProvider.notifier).record(track);
}
```

`RecentPlaysNotifier.record` does an `INSERT OR REPLACE` (UNIQUE constraint on track_id+source) and then trims to 200 rows by deleting oldest.

### Pattern 5: Playlist track storage as JSON blob

Store the full `TrackDto` as `jsonEncode(track.toJson())` in `track_json`. On read, decode with `TrackDto.fromJson(jsonDecode(row['track_json']))`. This avoids normalizing all TrackDto fields into columns and handles nullable fields cleanly.

### Pattern 6: Dio file download with progress

```dart
// Source: Dio 5.x docs — dio.download() API
final dir = await getExternalStorageDirectory();
final filePath = p.join(dir!.path, 'downloads', '${source}_${trackId}.${ext}');
await dio.download(
  '${AppConfig.apiBaseUrl}/download?track_id=...&source=...',
  filePath,
  options: Options(headers: {'X-API-Key': AppConfig.apiKey}),
  onReceiveProgress: (received, total) {
    if (total > 0) {
      // update DownloadNotifier progress
    }
  },
);
```

### Pattern 7: CustomScrollView with mixed sliver types

Library tab uses `CustomScrollView` with:
- `SliverAppBar` or `SliverToBoxAdapter` for AppBar
- `SliverToBoxAdapter` for Recent Plays horizontal ListView (fixed 108dp height)
- `SliverToBoxAdapter` for "Playlists" section header
- `SliverGrid` for playlist cards
- `SliverToBoxAdapter` for "Downloads" section header
- `SliverList` for download tiles
- `SliverToBoxAdapter` for empty state text in each section

### Anti-Patterns to Avoid

- **Opening DB per query:** Don't call `openDatabase` in each repository method — use the singleton Riverpod provider
- **Storing TrackDto fields in many columns:** Store as JSON blob instead — avoids repeated schema migrations when TrackDto evolves
- **Calling `ref.read(downloadsProvider)` inside build():** Use `ref.watch` for reactive state; `ref.read` only in callbacks
- **Forgetting to close IO streams:** Dio download streams are managed by Dio internals; do not wrap in StreamController manually
- **ReorderableListView with database index sync:** Always renumber `position` for all tracks in the playlist after reorder, not just the moved item — gaps cause undefined sort order

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SQLite access | Manual FFI or file parsing | sqflite 2.4.2 | Handles Android SQLite version quirks, WAL mode, async dispatch |
| File download with progress | Manual http stream reader | Dio `dio.download()` with `onReceiveProgress` | Already in project; handles redirects, retry, range headers |
| Path construction | String concatenation | `path` package `p.join()` | Platform-safe separator; avoids Windows-vs-Unix path bugs on dev machine |
| Playlist reorder | Floating-point position values (gap strategy) | Integer `position` renumber entire list | Simpler; no fraction accumulation bugs; playlist sizes are small |
| Track identity key | Backend-assigned UUID | `'${source}_${trackId}'` composite string key | No canonical cross-source ID (STATE.md decision — locked) |

---

## Common Pitfalls

### Pitfall 1: `getExternalStorageDirectory` returns null

**What goes wrong:** On Android emulators or if external storage is unmounted, `getExternalStorageDirectory()` returns null. Code that null-asserts (`dir!`) crashes.
**Why it happens:** External storage is not guaranteed to be available.
**How to avoid:** Fall back to `getApplicationDocumentsDirectory()` when null: `final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();`
**Warning signs:** NPE crash on first download attempt in emulator.

### Pitfall 2: Concurrent downloads exceed 3-parallel limit

**What goes wrong:** User taps download on 10 tracks quickly; all start simultaneously, hammering the backend.
**Why it happens:** No concurrency guard in download logic.
**How to avoid:** Use a `Semaphore` or check `state.values.where((e) => e.status == DownloadStatus.downloading).length >= 3` before starting a new download. Queue additional requests or show "queued" state.

### Pitfall 3: ReorderableListView index adjustment

**What goes wrong:** Moving a track downward produces wrong final position; the item jumps two steps.
**Why it happens:** ReorderableListView's `onReorder` passes `newIndex` as the position *after* the item is removed. When moving downward, `newIndex` is one higher than the actual target. This is the same issue already solved in `QueueNotifier.move()`.
**How to avoid:** Apply the same adjustment already in the codebase: `final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;`

### Pitfall 4: `track_json` field containing null coverUrl breaks CachedNetworkImage

**What goes wrong:** `CachedNetworkImage(imageUrl: '')` throws an assertion or shows broken image.
**Why it happens:** `TrackDto.coverUrl` is nullable; `jsonEncode` stores null correctly but the widget gets `null` or empty string at runtime.
**How to avoid:** Always use the existing null-coalescing pattern: `imageUrl: track.coverUrl ?? ''` with a placeholder fallback — already done in TrackListTile and must be copied to download tile and recent-play item.

### Pitfall 5: Recent plays UNIQUE constraint and "move to top" behavior

**What goes wrong:** Playing the same track twice inserts a duplicate, or triggers a constraint error.
**Why it happens:** If using plain `INSERT` instead of `INSERT OR REPLACE`.
**How to avoid:** Use `INSERT OR REPLACE INTO recent_plays (track_id, source, track_json, played_at) VALUES (?, ?, ?, ?)`. The UNIQUE(track_id, source) constraint causes the existing row to be deleted and re-inserted with the new `played_at` timestamp — naturally achieving "move to top."

### Pitfall 6: Download file persists after DB row deleted

**What goes wrong:** User sees stale files accumulating on disk.
**Why it happens:** If delete logic only removes the DB row without deleting the file.
**How to avoid:** In `DownloadNotifier.delete(track)`: (1) delete DB row, (2) call `File(localPath).deleteSync()`, (3) remove key from state map. All three steps must happen atomically in a DB transaction where possible.

### Pitfall 7: Playlist detail route parameter parsing

**What goes wrong:** `/library/playlist/:id` route passes `id` as String; SQLite expects int.
**Why it happens:** go_router passes all path params as String.
**How to avoid:** Parse with `int.parse(state.pathParameters['id']!)` in the route builder. Wrap in try/catch; redirect to `/library` on parse failure.

### Pitfall 8: Rebuilding all TrackListTile widgets on every download state change

**What goes wrong:** Search screen rebuilds 20+ tiles when any single download progresses.
**Why it happens:** `ref.watch(downloadsProvider)` watches the whole Map; any key change triggers rebuild of every watcher.
**How to avoid:** Use `ref.watch(downloadsProvider.select((map) => map['${track.source}_${track.trackId}']))` to watch only the specific entry. Each tile only rebuilds for its own track's state change.

---

## Code Examples

### SQLite DB open (singleton pattern)
```dart
// Source: sqflite 2.4.2 pub.dev documentation
final db = await openDatabase(
  path,
  version: 1,
  onCreate: (db, version) => db.execute('CREATE TABLE ...'),
);
```

### Insert or replace recent play
```dart
// Source: sqflite docs — conflict resolution algorithms
await db.rawInsert(
  'INSERT OR REPLACE INTO recent_plays (track_id, source, track_json, played_at) VALUES (?, ?, ?, ?)',
  [track.trackId, track.source, jsonEncode(track.toJson()), DateTime.now().millisecondsSinceEpoch],
);
// Trim to 200 entries
await db.rawDelete(
  'DELETE FROM recent_plays WHERE id NOT IN (SELECT id FROM recent_plays ORDER BY played_at DESC LIMIT 200)',
);
```

### Dio file download with progress
```dart
// Source: Dio 5.x README — download method
await ref.read(dioProvider).download(
  '$baseUrl/download?track_id=${Uri.encodeComponent(trackId)}&source=${Uri.encodeComponent(source)}',
  filePath,
  options: Options(headers: {'X-API-Key': AppConfig.apiKey}),
  onReceiveProgress: (received, total) {
    if (total > 0) {
      state = state.copyWith(trackKey, progress: received / total);
    }
  },
);
```

### Playlist tracks reorder
```dart
// Renumber all position values after reorder
Future<void> reorder(int playlistId, List<TrackDto> reorderedTracks) async {
  final db = await ref.read(databaseProvider.future);
  final batch = db.batch();
  for (var i = 0; i < reorderedTracks.length; i++) {
    batch.rawUpdate(
      'UPDATE playlist_tracks SET position = ? WHERE playlist_id = ? AND track_id = ? AND source = ?',
      [i, playlistId, reorderedTracks[i].trackId, reorderedTracks[i].source],
    );
  }
  await batch.commit(noResult: true);
}
```

### Download state selector (prevents full rebuild)
```dart
// Pattern: select a single entry to avoid rebuilding all tiles
final entry = ref.watch(
  downloadsProvider.select((map) => map['${track.source}_${track.trackId}']),
);
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Moor (ORM) | sqflite (direct SQL) | Moor renamed to drift ~2021, sqflite remains simpler choice | sqflite preferred for simple schemas |
| SharedPreferences for small lists | sqflite with proper schema | Always was best practice for relational data | Playlists need JOINs; SharedPreferences cannot do this |
| Storing file in app documents | `getExternalStorageDirectory` (this project) | Locked decision | Files survive app data clear in Settings |

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| sqflite | SQLite persistence | Resolved in pub cache | 2.4.2 | — |
| path_provider | Download file path | Resolved (transitive dep already present) | confirmed in pub cache | — |
| path | Path utilities | Standard Flutter transitive | 1.9.x | — |
| Dio | File download | In project already | 5.9.2 | — |
| Android external storage | Download files | Available on device (app-specific, no permission) | API 19+ | Fall back to `getApplicationDocumentsDirectory()` |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None.

---

## Open Questions

1. **Semaphore for 3-parallel download limit**
   - What we know: CONTEXT.md locks 3 parallel downloads max; Dart has no built-in semaphore
   - What's unclear: Whether a simple counter check (`downloading.length >= 3`) is sufficient or if a proper queue is needed
   - Recommendation: Simple counter check + "already downloading" guard is sufficient for v1; full queue is v2 scope (REQUIREMENTS.md marks background download queue as out of scope)

2. **DownloadNotifier initial state hydration**
   - What we know: On app restart, `DownloadNotifier` starts empty but the DB has all downloaded tracks
   - What's unclear: Should the notifier load all DB rows on init, or load lazily per-track?
   - Recommendation: Load all `downloads` rows on `build()` — typical row count is small (< 100) and avoids per-tile async gaps

3. **Playlist cover mosaic image loading**
   - What we know: Mosaic requires first 4 tracks' cover URLs from `playlist_tracks`
   - What's unclear: Whether to fetch cover URLs in the playlist list query (JOIN) or lazy-load per card
   - Recommendation: Include cover URLs in the playlist list query via a subquery or store them denormalized — avoids N+1 per card on the grid

---

## Sources

### Primary (HIGH confidence)
- sqflite 2.4.2 — verified in project pub cache via `flutter pub deps`; pub.dev docs fetched for API patterns
- path_provider 2.1.5 — verified on pub.dev
- Dio 5.9.2 — already in project pubspec.yaml; download API confirmed from project usage patterns
- Riverpod 3.3.1 / riverpod_generator 4.0.3 — existing project; `@Riverpod(keepAlive: true)` pattern confirmed from `queue_notifier.dart`
- Freezed 3.x `abstract class` requirement — confirmed in STATE.md project decisions
- `(source, identifier)` composite key — confirmed in STATE.md as locked pre-phase decision
- `QueueNotifier.playNow` as single entry point — confirmed from `queue_notifier.dart` source
- `_toAudioSource` pattern — read directly from `queue_notifier.dart`

### Secondary (MEDIUM confidence)
- `INSERT OR REPLACE` for recent plays "move to top" — sqflite conflict resolution, standard SQLite behavior
- Riverpod `select()` for partial state watching — established Riverpod pattern for performance

### Tertiary (LOW confidence)
- None — all critical claims verified against project source or official package documentation

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified versions from pub cache and pubspec.yaml
- Architecture: HIGH — patterns derived from existing project code (queue_notifier, track_list_tile, search_screen)
- Pitfalls: HIGH — all derived from existing codebase patterns or well-documented SQLite/Flutter gotchas

**Research date:** 2026-03-27
**Valid until:** 2026-04-27 (sqflite and path_provider are stable, low churn)
