---
phase: 04-library
verified: 2026-03-27T00:00:00Z
status: human_needed
score: 12/12 must-haves verified
human_verification:
  - test: "Download a track from search results and verify it appears in the Library Downloads section"
    expected: "Download icon on album art changes to progress indicator then checkmark; track appears in Library > Downloads with 'Offline' badge"
    why_human: "Requires actual network request to backend /download endpoint and file system write — cannot be verified without a running device"
  - test: "Play a downloaded track from Library Downloads and verify it plays without network"
    expected: "Track starts playing immediately with no network spinner; queue_notifier uses Uri.file path"
    why_human: "Requires offline mode verification on a real device"
  - test: "Create a playlist via FAB, add a track from search context menu, navigate to playlist detail"
    expected: "FAB opens name dialog; playlist card appears in grid; long-press on search result shows 'Add to Playlist'; picker shows the playlist; 'Added to {name}' SnackBar appears; playlist detail shows the track"
    why_human: "Full end-to-end UI flow requires interactive user input across multiple screens"
  - test: "Reorder tracks in playlist detail using drag handle"
    expected: "Drag handle is tappable; long-press drag moves track to new position; order persists after navigating away and back"
    why_human: "Drag gesture interaction cannot be verified statically"
  - test: "Swipe-to-delete a track in playlist detail"
    expected: "Red delete background appears; track removed from list; removal persists in DB"
    why_human: "Dismissible swipe gesture requires device interaction"
  - test: "Delete a playlist from the AppBar delete button"
    expected: "Confirmation dialog with playlist name appears; tapping 'Delete' pops back to Library; playlist no longer in grid"
    why_human: "Dialog interaction and navigation pop require device"
  - test: "Play a track and verify it appears in Recent Plays horizontal scroll"
    expected: "After playNow(), the track appears as the first item in the Recent Plays section of Library tab; tapping it replays"
    why_human: "Requires actual playback event to trigger RecentPlaysNotifier.record() and UI refresh"
  - test: "Long-press a search result and verify 'Add to Playlist' and 'Download' options in context menu"
    expected: "5-item bottom sheet appears with Play Now, Play Next, Add to Queue, Add to Playlist, Download"
    why_human: "Context menu rendering requires interactive long-press gesture"
  - test: "Verify full player secondary controls show Add to Playlist and Download buttons"
    expected: "When full player is open, bottom-left shows playlist_add icon and download icon (state-aware); tapping download starts download with Snackbar"
    why_human: "Requires player to be open with a track loaded"
---

# Phase 4: Library Verification Report

**Phase Goal:** Users can download tracks for offline use, manage local playlists, and review recently played tracks
**Verified:** 2026-03-27
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | SQLite database opens with 4 tables (playlists, playlist_tracks, recent_plays, downloads) | VERIFIED | `database_provider.dart` has full `CREATE TABLE` DDL for all 4 tables with correct schema |
| 2 | DownloadNotifier can download a track and report progress | VERIFIED | `download_notifier.dart:66-148` — Dio download with `onReceiveProgress`, DB insert, state update to `downloaded` |
| 3 | RecentPlaysNotifier records a played track and enforces 200-entry limit | VERIFIED | `recent_plays_notifier.dart:44-60` — `INSERT OR REPLACE` + trim to 200 via `DELETE ... NOT IN` subquery |
| 4 | PlaylistNotifier supports create, rename, delete, addTrack, removeTrack, reorderTrack | VERIFIED | `playlist_notifier.dart` — all 6 methods implemented with real DB queries and batch commits |
| 5 | QueueNotifier plays from local file when track is downloaded | VERIFIED | `queue_notifier.dart:43-59` — `_toAudioSource` checks `downloadsProvider.notifier.statusFor(key)`; uses `Uri.file(entry.localPath!)` |
| 6 | Library tab shows Recent Plays horizontal scroll, Playlists grid, Downloads list | VERIFIED | `library_screen.dart` — `CustomScrollView` with 3 sections, each wired to real providers |
| 7 | User can create a playlist via FAB and name dialog | VERIFIED | `library_screen.dart:242-251` — FAB calls `PlaylistNameDialog.show()` then `playlistsProvider.notifier.create(name)` |
| 8 | User can tap a playlist card to see its tracks in a detail screen | VERIFIED | `library_screen.dart:161-162` — `context.push('/library/playlist/${playlist.id}')` wired to `PlaylistDetailScreen` via go_router |
| 9 | User can reorder and swipe-to-delete tracks in playlist detail | VERIFIED | `playlist_detail_screen.dart` — `ReorderableListView.builder` + `Dismissible` both wired to `playlistsProvider.notifier` |
| 10 | User can delete a playlist with confirmation dialog | VERIFIED | `playlist_detail_screen.dart:257-309` — `AlertDialog` with "Keep playlist"/"Delete"; calls `notifier.delete()` then `nav.pop()` |
| 11 | User can add a track to a playlist via picker sheet (search + player) | VERIFIED | `search_screen.dart:128-131` calls `PlaylistPickerSheet.show()`; `full_player_sheet.dart:380-383` calls same |
| 12 | Download icon shows 3-state overlay on TrackListTile (notDownloaded/downloading/downloaded) | VERIFIED | `track_list_tile.dart:36-38` — `ref.watch(downloadsProvider.select((map) => map[trackKey]))` drives 3-branch switch |

**Score:** 12/12 truths verified

---

### Required Artifacts

#### Plan 01 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/core/db/database_provider.dart` | Singleton SQLite with 4 tables | VERIFIED | 67 lines; all 4 `CREATE TABLE` statements present; `PRAGMA foreign_keys = ON` |
| `mobile/lib/core/models/download_entry.dart` | DownloadEntry Freezed + DownloadStatus enum | VERIFIED | `enum DownloadStatus`, `@freezed` `DownloadEntry` with status/progress/localPath/fileSize |
| `mobile/lib/features/downloads/download_notifier.dart` | Downloads notifier with download/delete/statusFor/allDownloads | VERIFIED | 177 lines; all 4 methods implemented; 3-parallel limit enforced |
| `mobile/lib/features/library/recent_plays_notifier.dart` | RecentPlays notifier with record() and reload() | VERIFIED | 63 lines; `INSERT OR REPLACE`; 200-entry trim; `_load()` on build |
| `mobile/lib/features/library/playlist_notifier.dart` | Playlists notifier with create/rename/delete/addTrack/removeTrack/reorderTrack | VERIFIED | 164 lines; all 6 mutations with real DB queries |
| `mobile/lib/core/models/playlist_model.dart` | PlaylistModel Freezed | VERIFIED | `@freezed` with id/name/createdAt/trackCount/coverUrls |
| `mobile/lib/core/models/recent_play.dart` | RecentPlay Freezed | VERIFIED | `@freezed` with track/playedAt |

#### Plan 02 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/library/library_screen.dart` | CustomScrollView with 3 sections, FAB | VERIFIED | 304 lines; `CustomScrollView`, `FloatingActionButton`, all 3 sections with empty states |
| `mobile/lib/features/library/widgets/playlist_card.dart` | 2-column card with cover mosaic | VERIFIED | 159 lines; `class PlaylistCard`; `_buildMosaic()` with 0/1-3/4+ URL branches |
| `mobile/lib/features/library/playlist_detail_screen.dart` | ReorderableListView with swipe-to-delete | VERIFIED | 311 lines; `ReorderableListView.builder`, `Dismissible`, delete confirmation dialog |
| `mobile/lib/features/library/dialogs/playlist_name_dialog.dart` | AlertDialog for create/rename | VERIFIED | 120 lines; `class PlaylistNameDialog`; static `show()`; validate-on-empty; `0xFF1DB954` accent |
| `mobile/lib/features/library/dialogs/playlist_picker_sheet.dart` | Bottom sheet for Add to Playlist | VERIFIED | 178 lines; `class PlaylistPickerSheet`; "New playlist" option + existing playlists; SnackBar "Added to {name}" |

#### Plan 03 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `mobile/lib/features/search/widgets/track_list_tile.dart` | Download state overlay on album art | VERIFIED | 166 lines; `ConsumerWidget`; `downloadsProvider.select()`; 3-state switch with GestureDetector/CircularProgressIndicator/Icon |
| `mobile/lib/features/search/search_screen.dart` | 5-item context menu with Add to Playlist + Download | VERIFIED | "Add to Playlist" calls `PlaylistPickerSheet.show()`; "Download" calls `downloadsProvider.notifier.download(track)` with SnackBar |
| `mobile/lib/features/player/full_player_sheet.dart` | Secondary controls with playlist add + download | VERIFIED | `Icons.playlist_add` calls `PlaylistPickerSheet.show()`; `_DownloadButton` ConsumerWidget watches `downloadsProvider.select()` |

---

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `queue_notifier.dart` | `download_notifier.dart` | `ref.read(downloadsProvider.notifier).statusFor(key)` in `_toAudioSource` | WIRED | Line 44: `ref.read(downloadsProvider.notifier).statusFor(key)` |
| `queue_notifier.dart` | `recent_plays_notifier.dart` | `ref.read(recentPlaysProvider.notifier).record(track)` in `playNow` | WIRED | Line 97: `ref.read(recentPlaysProvider.notifier).record(track)` |
| `download_notifier.dart` | `database_provider.dart` | `ref.read(databaseProvider.future)` | WIRED | Lines 35, 122 use `databaseProvider.future` |
| `library_screen.dart` | `playlist_notifier.dart` | `ref.watch(playlistsProvider)` | WIRED | Lines 50, 249 |
| `library_screen.dart` | `recent_plays_notifier.dart` | `ref.watch(recentPlaysProvider)` | WIRED | Line 49 |
| `library_screen.dart` | `download_notifier.dart` | `ref.read(downloadsProvider.notifier).allDownloads()` | WIRED | Lines 41, 53 |
| `app.dart` | `playlist_detail_screen.dart` | `GoRoute path: 'playlist/:id'` | WIRED | Lines 74-82; `int.parse(state.pathParameters['id']!)` |
| `track_list_tile.dart` | `download_notifier.dart` | `ref.watch(downloadsProvider.select(...))` | WIRED | Line 37: `downloadsProvider.select((map) => map[trackKey])` |
| `search_screen.dart` | `playlist_picker_sheet.dart` | `PlaylistPickerSheet.show()` | WIRED | Line 130 |
| `full_player_sheet.dart` | `download_notifier.dart` | `ref.watch(downloadsProvider.select(...))` | WIRED | Line 472 |

---

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|--------------------|--------|
| `library_screen.dart` (Recent Plays) | `recentPlays` from `ref.watch(recentPlaysProvider)` | `recent_plays_notifier.dart` — `db.query('recent_plays', orderBy: 'played_at DESC', limit: 200)` | Yes — real DB query | FLOWING |
| `library_screen.dart` (Playlists) | `playlists` from `ref.watch(playlistsProvider)` | `playlist_notifier.dart` — `db.rawQuery(...)` with COUNT, GROUP_CONCAT | Yes — real DB query | FLOWING |
| `library_screen.dart` (Downloads) | `_downloads` from `allDownloads()` | `download_notifier.dart` — `db.query('downloads', orderBy: 'downloaded_at DESC')` | Yes — real DB query | FLOWING |
| `playlist_detail_screen.dart` | `_tracks` from `tracksForPlaylist(id)` | `playlist_notifier.dart` — `db.query('playlist_tracks', where: 'playlist_id = ?', ...)` | Yes — real DB query | FLOWING |
| `track_list_tile.dart` | `entry` from `downloadsProvider.select()` | `download_notifier.dart` — `_hydrate()` loads from `downloads` table on build | Yes — DB-backed map | FLOWING |

---

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Flutter analyze — data layer | `flutter analyze lib/features/library/ lib/features/downloads/download_notifier.dart lib/core/db/database_provider.dart lib/core/audio/queue_notifier.dart` | No issues found | PASS |
| Flutter analyze — UI/search/player | `flutter analyze lib/features/search/widgets/track_list_tile.dart lib/features/search/search_screen.dart lib/features/player/full_player_sheet.dart lib/app.dart` | No issues found | PASS |
| Generated .g.dart files present | `ls database_provider.g.dart download_notifier.g.dart playlist_notifier.g.dart recent_plays_notifier.g.dart queue_notifier.g.dart` | All 5 exist | PASS |
| Route `playlist/:id` registered | `grep 'playlist/:id' app.dart` | Found at line 75 with `int.parse(state.pathParameters['id']!)` | PASS |

---

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| DL-01 | 04-01, 04-03 | User can download a track from search results or player | SATISFIED | `download_notifier.dart:66-148` (Dio file download); search context menu + full player `_DownloadButton` both call `downloadsProvider.notifier.download(track)` |
| DL-02 | 04-01, 04-03 | Downloaded tracks show download status indicator | SATISFIED | `track_list_tile.dart:36-165` — 3-state overlay (download icon / progress / checkmark); `full_player_sheet.dart` `_DownloadButton` same 3 states |
| DL-03 | 04-02 | User can browse downloads library showing all locally stored tracks | SATISFIED | `library_screen.dart:180-233` — Downloads section with `SliverList` of `DownloadTile` widgets loaded from `allDownloads()` DB query. Per CONTEXT.md design decision, DL-03 is fulfilled by the Library tab Downloads section, not the `/downloads` tab (which is a pre-existing Phase 2 placeholder intentionally out of scope). |
| DL-04 | 04-01, 04-03 | Downloaded tracks play from local file without network | SATISFIED | `queue_notifier.dart:43-59` — `_toAudioSource` uses `Uri.file(entry.localPath!)` when `DownloadStatus.downloaded` |
| PLIST-01 | 04-02 | User can create a named playlist | SATISFIED | FAB → `PlaylistNameDialog.show()` → `playlistsProvider.notifier.create(name)` |
| PLIST-02 | 04-02 | User can add a song to a playlist from search results or player | SATISFIED | Search context menu + full player both call `PlaylistPickerSheet.show()` → `playlistsProvider.notifier.addTrack()` |
| PLIST-03 | 04-02 | User can remove a song from a playlist | SATISFIED | `playlist_detail_screen.dart:124-129` — `Dismissible.onDismissed` calls `playlistsProvider.notifier.removeTrack()` |
| PLIST-04 | 04-02 | User can view playlist contents with track list | SATISFIED | `playlist_detail_screen.dart` — loads `tracksForPlaylist(id)` from DB; renders `ReorderableListView.builder` |
| PLIST-05 | 04-02 | User can delete a playlist with confirmation | SATISFIED | AppBar delete button → `AlertDialog` with "Delete" destructive button → `playlistsProvider.notifier.delete(id)` → `nav.pop()` |
| PLIST-06 | 04-02 | User can reorder tracks within a playlist | SATISFIED | `playlist_detail_screen.dart:245-254` — `onReorder` calls `playlistsProvider.notifier.reorderTrack()` with correct index adjustment |
| REC-01 | 04-01 | App records recently played tracks automatically | SATISFIED | `queue_notifier.dart:97` — `ref.read(recentPlaysProvider.notifier).record(track)` called in every `playNow()` |
| REC-02 | 04-02 | User can view recent plays list and tap to replay | SATISFIED | `library_screen.dart:97-113` — horizontal `ListView` of `RecentPlayItem`; tap calls `queueProvider.notifier.playNow(item.track)` |

---

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `mobile/lib/features/downloads/downloads_screen.dart` | 9 | `Text('Coming soon')` — stub screen at `/downloads` tab | Info | NOT a blocker — this is a pre-existing Phase 2 placeholder. Per CONTEXT.md design decision, DL-03 (downloads browsing) is fulfilled by the Library tab's Downloads section. The `/downloads` tab is out of scope for Phase 4. |

---

### Human Verification Required

The following behaviors require on-device testing and cannot be verified statically:

#### 1. Download Flow End-to-End

**Test:** Search for a track, tap the green download icon on the album art thumbnail.
**Expected:** Icon changes to `CircularProgressIndicator` with green accent, then to `check_circle` icon when complete. Track appears in Library tab → Downloads section with track name, artist, file size, and "Offline" badge.
**Why human:** Requires a running backend `/download` endpoint, actual file write to device storage, and real-time provider state updates across widgets.

#### 2. Offline Playback

**Test:** Enable airplane mode, then tap a downloaded track in the Library Downloads section.
**Expected:** Track plays immediately from local file (no network spinner), no errors. `queue_notifier._toAudioSource` should select `Uri.file(localPath)`.
**Why human:** Requires device network control and actual audio playback verification.

#### 3. Playlist Creation and Track Addition

**Test:** Tap the green (+) FAB on Library tab → type playlist name → tap "Create Playlist". Then long-press a search result → "Add to Playlist" → select the playlist.
**Expected:** Playlist card appears in the 2-column grid. Picker shows the playlist with track count. After selection, SnackBar shows "Added to {name}". Playlist detail shows the track.
**Why human:** Requires multi-step gesture interaction across screens with persistent state.

#### 4. Track Reorder in Playlist Detail

**Test:** Navigate to a playlist with 2+ tracks. Long-press the drag handle (`Icons.drag_handle`) and drag a track to a new position.
**Expected:** Track moves to new position immediately (optimistic UI). After navigating away and back, order persists.
**Why human:** Drag gesture interaction requires physical device interaction; DB persistence requires navigation.

#### 5. Swipe-to-Delete Track

**Test:** In playlist detail, swipe a track from right to left past the dismiss threshold.
**Expected:** Red delete background with white trash icon appears. Track is removed from list. Remaining tracks renumber positions in DB.
**Why human:** Dismissible swipe gesture requires physical interaction.

#### 6. Delete Playlist with Confirmation

**Test:** In playlist detail, tap the trash icon in AppBar.
**Expected:** `AlertDialog` with "Delete playlist?" title, playlist name in body, "Keep playlist" and "Delete" (red) buttons. Tapping "Delete" returns to Library tab with playlist removed from grid.
**Why human:** Dialog interaction and navigation pop require physical interaction.

#### 7. Recent Plays Recording

**Test:** Play 3 different tracks via search. Navigate to Library tab.
**Expected:** Recent Plays horizontal scroll shows the 3 tracks in reverse chronological order (most recent first). Tapping any item starts playback of that track.
**Why human:** Requires actual playback events to trigger `recentPlaysProvider.notifier.record()` and provider state refresh.

#### 8. Search Context Menu and Full Player Buttons

**Test:** Long-press a search result; open full player.
**Expected:** Context menu shows 5 items including "Add to Playlist" and "Download". Full player secondary row shows `playlist_add` icon (left) and download icon (download state-aware, right side shows queue button).
**Why human:** Context menu requires long-press gesture; full player requires a track to be playing.

---

### Gaps Summary

No automated gaps found. All artifacts exist, are substantive, are wired to real data sources, and pass `flutter analyze`. The 9 human verification items listed above are standard end-to-end behavioral checks that require on-device interaction to validate the complete user experience.

**DL-03 clarification:** The `/downloads` tab route (`downloads_screen.dart`) is a pre-existing Phase 2 placeholder. Phase 4 intentionally fulfills DL-03 via the Library tab's Downloads section (per CONTEXT.md decision: "Three sections on Library tab: 'Recent Plays' (top), 'Playlists' (middle), 'Downloads' (bottom)"). This is not a gap — it is the specified architecture.

---

_Verified: 2026-03-27_
_Verifier: Claude (gsd-verifier)_
