---
phase: 04-library
plan: 02
subsystem: ui
tags: [flutter, riverpod, go_router, library, playlists, recent-plays, downloads, material3]

# Dependency graph
requires:
  - phase: 04-library
    plan: 01
    provides: PlaylistNotifier, RecentPlaysNotifier, DownloadNotifier, PlaylistModel, RecentPlay, DownloadEntry models

provides:
  - LibraryScreen: CustomScrollView with Recent Plays horizontal scroll, Playlists 2-column grid, Downloads sliver list
  - RecentPlayItem widget: 72x72dp cover art + track name item for horizontal scroll
  - PlaylistCard widget: 2-column card with cover mosaic (2x2 quadrant grid or placeholder)
  - DownloadTile widget: ListTile with Offline badge, file size, Icons.more_vert bottom sheet
  - PlaylistDetailScreen: ReorderableListView with drag handles + Dismissible swipe-to-delete + AppBar delete
  - PlaylistNameDialog: reusable AlertDialog for create/rename flows
  - PlaylistPickerSheet: modal bottom sheet for Add to Playlist with New playlist option
  - GoRoute playlist/:id registered in app.dart under /library branch

affects:
  - 04-library plan 03 (TrackListTile download overlay + search context menu Add to Playlist/Download)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ConsumerStatefulWidget with _loadDownloads on initState + ref.listen reload pattern for downloadsProvider
    - Force git add -f required for new files in mobile/lib/ due to root .gitignore lib/ pattern from Python project
    - Navigator captured before async gap to satisfy use_build_context_synchronously lint

key-files:
  created:
    - mobile/lib/features/library/library_screen.dart
    - mobile/lib/features/library/widgets/recent_play_item.dart
    - mobile/lib/features/library/widgets/playlist_card.dart
    - mobile/lib/features/library/widgets/download_tile.dart
    - mobile/lib/features/library/playlist_detail_screen.dart
    - mobile/lib/features/library/dialogs/playlist_name_dialog.dart
    - mobile/lib/features/library/dialogs/playlist_picker_sheet.dart
  modified:
    - mobile/lib/app.dart (added playlist/:id child route under /library, imported PlaylistDetailScreen)

key-decisions:
  - "git add -f required for all new files in mobile/lib/ — root .gitignore has lib/ pattern from Python project conventions"
  - "Navigator captured before showDialog await to satisfy use_build_context_synchronously — nav variable holds reference before async gap"
  - "PlaylistDetailScreen uses ConsumerStatefulWidget with local _tracks state — allows optimistic UI on reorder/dismiss before DB completes"
  - "Dismissible key includes index to ensure uniqueness when list changes — prevents accidental dismissal after reorder"

patterns-established:
  - "Capture BuildContext-derived objects (Navigator, ScaffoldMessenger) before await gaps"
  - "ConsumerStatefulWidget local list state pattern for ReorderableListView — mutable state + ref.read for DB mutations"
  - "LayoutBuilder + GridView.count for cover mosaic quadrants — adapts to card width without fixed pixel values"

requirements-completed: [PLIST-01, PLIST-02, PLIST-03, PLIST-04, PLIST-05, PLIST-06, DL-03, REC-02]

# Metrics
duration: 9min
completed: 2026-03-27
---

# Phase 4 Plan 02: Library UI Summary

**Full Library tab UI with 3-section CustomScrollView (Recent Plays, Playlists grid, Downloads), PlaylistDetailScreen with reorder/swipe-delete, PlaylistNameDialog, PlaylistPickerSheet, and playlist route in go_router**

## Performance

- **Duration:** 9 min
- **Started:** 2026-03-27T09:13:43Z
- **Completed:** 2026-03-27T09:22:52Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Replaced Library "Coming soon" placeholder with full 3-section ConsumerStatefulWidget using CustomScrollView — Recent Plays horizontal scroll (10 items, 108dp height), Playlists SliverGrid (2-column, 0.85 aspect ratio), Downloads SliverList
- Created 3 sub-widgets (RecentPlayItem, PlaylistCard with cover mosaic, DownloadTile with Offline badge) and 2 dialogs/sheets (PlaylistNameDialog reusable for create+rename, PlaylistPickerSheet with New playlist + existing lists)
- Built PlaylistDetailScreen with ReorderableListView.builder + drag handles + Dismissible swipe-to-delete + confirmation dialog; all playlist CRUD operations wired to playlistsProvider.notifier
- Added `/library/playlist/:id` child GoRoute in app.dart, completing the playlist navigation chain

## Task Commits

Each task was committed atomically:

1. **Task 1: Library tab UI with 3 sections, FAB, and widget components** - `5eded6f` (feat)
2. **Task 2: Playlist Detail screen, dialogs, picker sheet, and add route** - `8af95d8` (feat)

**Plan metadata:** (docs commit hash below)

## Files Created/Modified

- `mobile/lib/features/library/library_screen.dart` — ConsumerStatefulWidget; CustomScrollView with SliverAppBar, 3 sections with section headers, empty states; FAB opens PlaylistNameDialog; long-press playlist shows rename/delete sheet
- `mobile/lib/features/library/widgets/recent_play_item.dart` — 80dp wide Column with 72x72dp CachedNetworkImage + 2-line track name; semanticLabel on cover
- `mobile/lib/features/library/widgets/playlist_card.dart` — Card(0xFF1E1E1E) with cover mosaic (LayoutBuilder + GridView.count for 2x2 quadrants), name 16sp/600, track count 14sp/400 #9E9E9E; Semantics label
- `mobile/lib/features/library/widgets/download_tile.dart` — Card(0xFF1E1E1E) wrapping isThreeLine ListTile; Offline chip #424242; Icons.more_vert opens bottom sheet with Play Now and Delete
- `mobile/lib/features/library/playlist_detail_screen.dart` — ConsumerStatefulWidget; ReorderableListView.builder with ReorderableDragStartListener; Dismissible with #E53935 background; delete confirmation AlertDialog
- `mobile/lib/features/library/dialogs/playlist_name_dialog.dart` — StatefulWidget AlertDialog; autofocus TextField; Never mind + accent confirm button disabled on empty; max 50 chars
- `mobile/lib/features/library/dialogs/playlist_picker_sheet.dart` — showModalBottomSheet; New playlist with accent Icons.add; existing playlists with 40dp thumbnails; Added to {name} SnackBar
- `mobile/lib/app.dart` — added playlist/:id child GoRoute under /library, imported PlaylistDetailScreen

## Decisions Made

- `git add -f` required for all new files in `mobile/lib/` — root `.gitignore` has `lib/` pattern (Python convention) that ignores the Flutter source tree. Previously committed files work because they were already tracked; new files need force-add.
- `Navigator.of(context)` captured before `showDialog` await and before `delete` await to satisfy `use_build_context_synchronously` lint requirement.
- PlaylistDetailScreen uses local `_tracks` state (not `ref.watch`) for optimistic reorder/dismiss — UI responds instantly while DB mutation runs async.
- `Dismissible` key includes index (`${source}_${trackId}_$index`) to ensure uniqueness after list mutations.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed unused import in playlist_detail_screen.dart**
- **Found during:** Task 2 (flutter analyze after file creation)
- **Issue:** `import '../search/widgets/track_list_tile.dart'` was imported but not used — the plan specified using "same visual structure as TrackListTile" which was implemented inline as a ListTile, not via the widget
- **Fix:** Removed the unused import
- **Files modified:** `mobile/lib/features/library/playlist_detail_screen.dart`
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** `8af95d8` (Task 2 commit)

**2. [Rule 1 - Bug] Fixed use_build_context_synchronously lint in _showDeleteDialog**
- **Found during:** Task 2 (flutter analyze after file creation)
- **Issue:** `Navigator.of(context)` called after `showDialog` await — linter flags this as unsafe BuildContext use across async gaps
- **Fix:** Captured `final nav = Navigator.of(context)` before the `showDialog` await call
- **Files modified:** `mobile/lib/features/library/playlist_detail_screen.dart`
- **Verification:** `flutter analyze` reports no issues
- **Committed in:** `8af95d8` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (2 bugs)
**Impact on plan:** Both were compile/lint errors that needed fixing for clean code. No scope creep.

## Known Stubs

None — all data sources are wired to real Riverpod providers from Plan 01. The LibraryScreen reads from `recentPlaysProvider`, `playlistsProvider`, and `downloadsProvider.notifier.allDownloads()`. Empty states are intentional UI states (no data yet), not stubs.

## Issues Encountered

- Root `.gitignore` `lib/` pattern required `git add -f` for all new files under `mobile/lib/`. Pre-existing tracked files were unaffected. This is a known quirk of co-locating Flutter and Python projects in the same repo.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Library tab is fully interactive: FAB creates playlists, tapping playlist cards navigates to detail, reorder and swipe-to-delete work, download tiles play from local file
- Plan 03 can now wire up the remaining UI touchpoints: TrackListTile download overlay (not-downloaded/downloading/downloaded states), search context menu "Add to Playlist" and "Download" options, full player secondary controls row (Add to Playlist + Download buttons)
- PlaylistPickerSheet is imported and ready to use from search_screen.dart's `_showTrackContextMenu`

---
*Phase: 04-library*
*Completed: 2026-03-27*
