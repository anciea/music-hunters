---
phase: 04-library
plan: 01
subsystem: database
tags: [sqflite, flutter, riverpod, freezed, downloads, playlists, recent-plays, sqlite]

# Dependency graph
requires:
  - phase: 03-audio-playback
    provides: QueueNotifier and AudioHandler for playback integration
  - phase: 02-flutter-shell-search
    provides: TrackDto model, dioProvider, Riverpod setup, go_router navigation

provides:
  - SQLite database provider with 4 tables (playlists, playlist_tracks, recent_plays, downloads)
  - DownloadEntry Freezed model with DownloadStatus enum
  - PlaylistModel Freezed model with coverUrls aggregation
  - RecentPlay Freezed model pairing TrackDto with playedAt
  - DownloadNotifier: download/delete/statusFor/allDownloads with 3-parallel limit
  - PlaylistNotifier: create/rename/delete/addTrack/removeTrack/reorderTrack
  - RecentPlaysNotifier: record with INSERT OR REPLACE + 200-entry trim
  - QueueNotifier modified: local file playback via Uri.file + auto-record recent plays

affects:
  - 04-library plans 02 and 03 (all UI tasks depend on these notifiers)

# Tech tracking
tech-stack:
  added:
    - sqflite 2.4.2 (SQLite for Flutter)
    - path_provider 2.1.5 (platform storage directories)
    - path 1.9.0 (path joining utilities)
  patterns:
    - SQLite singleton via Riverpod keepAlive Future provider
    - Freezed models without JSON serialization for local-only state
    - Hydrate-on-build pattern: synchronous empty initial state, async DB load in background
    - Track key pattern: 'source_trackId' composite string for Map lookups
    - INSERT OR REPLACE for upsert semantics in recent_plays

key-files:
  created:
    - mobile/lib/core/db/database_provider.dart
    - mobile/lib/core/db/database_provider.g.dart
    - mobile/lib/core/models/download_entry.dart
    - mobile/lib/core/models/download_entry.freezed.dart
    - mobile/lib/core/models/playlist_model.dart
    - mobile/lib/core/models/playlist_model.freezed.dart
    - mobile/lib/core/models/recent_play.dart
    - mobile/lib/core/models/recent_play.freezed.dart
    - mobile/lib/features/downloads/download_notifier.dart
    - mobile/lib/features/downloads/download_notifier.g.dart
    - mobile/lib/features/library/playlist_notifier.dart
    - mobile/lib/features/library/playlist_notifier.g.dart
    - mobile/lib/features/library/recent_plays_notifier.dart
    - mobile/lib/features/library/recent_plays_notifier.g.dart
  modified:
    - mobile/pubspec.yaml (added sqflite, path_provider, path)
    - mobile/lib/core/audio/queue_notifier.dart (local file playback + recent plays)

key-decisions:
  - "downloadsProvider.notifier.statusFor() not downloadsProvider.statusFor() — provider state is Map, statusFor is a notifier method"
  - "ConflictAlgorithm imported from sqflite, not standalone — required for db.insert with replace semantics"
  - "Hydrate-on-build: build() returns empty synchronously then _hydrate() populates async — avoids FutureProvider complexity for keepAlive notifiers"
  - "Track key pattern '${source}_${trackId}' used consistently across DownloadNotifier and QueueNotifier for O(1) lookup"

patterns-established:
  - "Keepalive Riverpod notifier + async _load/_hydrate on build: standard pattern for SQLite-backed list state"
  - "All SQLite mutations reload state via _load() for consistency — no optimistic updates"

requirements-completed: [DL-01, DL-02, DL-04, REC-01]

# Metrics
duration: 5min
completed: 2026-03-27
---

# Phase 4 Plan 01: Data Layer Summary

**SQLite database (4 tables) + 3 Riverpod keepAlive notifiers (Downloads, Playlists, RecentPlays) + QueueNotifier modified for local file playback and automatic recent play recording**

## Performance

- **Duration:** 5 min
- **Started:** 2026-03-27T09:04:15Z
- **Completed:** 2026-03-27T09:09:56Z
- **Tasks:** 2
- **Files modified:** 16

## Accomplishments

- Created SQLite database provider with 4 tables: playlists, playlist_tracks, recent_plays, downloads — with CASCADE deletes and PRAGMA foreign_keys = ON
- Built 3 Freezed data models (DownloadEntry with DownloadStatus enum, PlaylistModel with coverUrls, RecentPlay with TrackDto) and generated all code
- Created 3 Riverpod keepAlive notifiers — DownloadNotifier (3-parallel limit, Dio progress callbacks, DB hydration with file existence check), PlaylistNotifier (full CRUD + addTrack/removeTrack/reorderTrack), RecentPlaysNotifier (INSERT OR REPLACE, 200-entry trim)
- Modified QueueNotifier to check local downloads before building stream URI, and to auto-record played track via RecentPlaysNotifier

## Task Commits

Each task was committed atomically:

1. **Task 1: Add packages, create SQLite database provider and Freezed models** - `7c40062` (feat)
2. **Task 2: Create DownloadNotifier, PlaylistNotifier, RecentPlaysNotifier, and modify QueueNotifier** - `050dc97` (feat)

## Files Created/Modified

- `mobile/pubspec.yaml` — added sqflite 2.4.2, path_provider 2.1.5, path 1.9.0
- `mobile/lib/core/db/database_provider.dart` — keepAlive Riverpod provider; opens musicdl.db; creates 4 tables with correct constraints
- `mobile/lib/core/models/download_entry.dart` — Freezed model; DownloadStatus enum (notDownloaded/downloading/downloaded); progress, localPath, fileSize fields
- `mobile/lib/core/models/playlist_model.dart` — Freezed model; id, name, createdAt, trackCount, coverUrls fields
- `mobile/lib/core/models/recent_play.dart` — Freezed model; TrackDto + playedAt timestamp
- `mobile/lib/features/downloads/download_notifier.dart` — keepAlive notifier; Map<String, DownloadEntry> state; download/delete/statusFor/allDownloads; 3-parallel limit; DB hydration on build
- `mobile/lib/features/library/playlist_notifier.dart` — keepAlive notifier; List<PlaylistModel> state; full CRUD + track management; GROUP_CONCAT SQL for cover URLs
- `mobile/lib/features/library/recent_plays_notifier.dart` — keepAlive notifier; List<RecentPlay> state; INSERT OR REPLACE; 200-entry trim
- `mobile/lib/core/audio/queue_notifier.dart` — added local file check in _toAudioSource; added recentPlaysProvider.notifier.record() in playNow
- Generated: database_provider.g.dart, download_entry.freezed.dart, playlist_model.freezed.dart, recent_play.freezed.dart, download_notifier.g.dart, playlist_notifier.g.dart, recent_plays_notifier.g.dart, queue_notifier.g.dart

## Decisions Made

- `downloadsProvider.notifier.statusFor()` not `downloadsProvider.statusFor()` — the provider state is `Map<String, DownloadEntry>`; `statusFor` is a method on the notifier class, not the state map.
- `ConflictAlgorithm` must be imported from `sqflite` — not available standalone in the dio/riverpod namespace.
- Hydrate-on-build pattern: `build()` returns empty synchronously, `_hydrate()/_load()` populates async. Avoids FutureProvider complexity while keeping notifiers keepAlive and writable.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed undefined_method on downloadsProvider state**
- **Found during:** Task 2 (QueueNotifier modification)
- **Issue:** `ref.read(downloadsProvider).statusFor(key)` — `downloadsProvider` returns `Map<String, DownloadEntry>`, which has no `statusFor` method
- **Fix:** Changed to `ref.read(downloadsProvider.notifier).statusFor(key)`
- **Files modified:** `mobile/lib/core/audio/queue_notifier.dart`
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** `050dc97` (Task 2 commit)

**2. [Rule 3 - Blocking] Added missing sqflite import for ConflictAlgorithm**
- **Found during:** Task 2 (DownloadNotifier creation)
- **Issue:** `ConflictAlgorithm.replace` used in `db.insert` but `sqflite` not imported in download_notifier.dart
- **Fix:** Added `import 'package:sqflite/sqflite.dart';` to download_notifier.dart
- **Files modified:** `mobile/lib/features/downloads/download_notifier.dart`
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** `050dc97` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 blocking)
**Impact on plan:** Both necessary for compilation. No scope creep.

## Issues Encountered

None beyond the two auto-fixed compile errors.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Full data layer is in place: database, models, notifiers
- Plans 02 and 03 (Library screen UI + Download UI) can proceed immediately
- All 3 notifiers are keepAlive and will hydrate from SQLite on first access
- QueueNotifier now automatically records recent plays — no UI wiring needed for that feature

---
*Phase: 04-library*
*Completed: 2026-03-27*
