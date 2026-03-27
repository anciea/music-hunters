---
phase: 04-library
plan: 03
subsystem: ui
tags: [flutter, riverpod, download, playlist, search, player]

# Dependency graph
requires:
  - phase: 04-01
    provides: downloadsProvider, DownloadEntry, DownloadStatus — download state management
  - phase: 04-02
    provides: PlaylistPickerSheet.show() — playlist picker bottom sheet

provides:
  - TrackListTile with 3-state download overlay on album art (download / progress / checkmark)
  - Search context menu extended with "Add to Playlist" and "Download" options (5 items total)
  - Full player secondary controls row with Add to Playlist + Download buttons on left, queue on right

affects: [04-04-library-screen, future search surfaces, player extensions]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "downloadsProvider.select((map) => map[key]) — selective provider watching prevents full-list rebuilds"
    - "GestureDetector wrapping Icon for tappable overlay without IconButton layout overhead"
    - "_DownloadButton ConsumerWidget at bottom of file — private widget for isolated provider subscription"
    - "Semantics wrapper with dynamic label (not const) for accessibility on progress states"

key-files:
  created: []
  modified:
    - mobile/lib/features/search/widgets/track_list_tile.dart
    - mobile/lib/features/search/search_screen.dart
    - mobile/lib/features/player/full_player_sheet.dart

key-decisions:
  - "TrackListTile changed from StatelessWidget to ConsumerWidget — necessary to watch downloadsProvider for overlay state"
  - "GestureDetector used for download icon tap in overlay (not IconButton) — avoids layout constraints interfering with 48x48 SizedBox parent"
  - "_DownloadButton extracted as private ConsumerWidget in full_player_sheet.dart — scopes provider subscription to button only, avoids rebuilding entire FullPlayerSheet on download progress changes"
  - "SizedBox(width: 48, height: 48) wraps leading Stack in TrackListTile — maintains consistent tile dimensions when overlay switches between icon (24) and progress indicator (20)"

patterns-established:
  - "Download overlay pattern: Stack + Positioned(right:0,bottom:0) on album art thumbnail"
  - "3-state download widget: notDownloaded → GestureDetector+Icon, downloading → Semantics+CircularProgressIndicator, downloaded → Semantics+Icon"
  - "Context menu 5-item pattern: Play Now, Play Next, Add to Queue, Add to Playlist, Download"

requirements-completed: [DL-01, DL-02, DL-04]

# Metrics
duration: 2min
completed: 2026-03-27
---

# Phase 04 Plan 03: UI Download Integration Summary

**Download state overlay on TrackListTile album art + 5-item search context menu + full player secondary controls with playlist-add and download buttons wired to downloadsProvider and PlaylistPickerSheet**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-27T09:27:36Z
- **Completed:** 2026-03-27T09:29:36Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- TrackListTile upgraded from StatelessWidget to ConsumerWidget with a 3-state download overlay (green download icon / circular progress / green check circle) positioned at the bottom-right of the 48x48 album art using selective provider watching
- Search context menu extended from 3 to 5 items: Play Now, Play Next, Add to Queue (existing), + Add to Playlist (opens PlaylistPickerSheet) and Download (triggers download + SnackBar confirmation)
- Full player secondary controls row restructured from right-aligned single queue button to spaceBetween row with left-side Add to Playlist + `_DownloadButton` ConsumerWidget alongside right-side queue button

## Task Commits

1. **Task 1: Add download overlay to TrackListTile and extend search context menu** - `4e9d709` (feat)
2. **Task 2: Add download and playlist buttons to full player secondary controls** - `8e9ce29` (feat)

## Files Created/Modified

- `mobile/lib/features/search/widgets/track_list_tile.dart` — Changed to ConsumerWidget; album art wrapped in SizedBox+Stack with Positioned download overlay; imports download_notifier and download_entry
- `mobile/lib/features/search/search_screen.dart` — Extended _showTrackContextMenu with Add to Playlist (PlaylistPickerSheet.show) and Download (downloadsProvider.notifier.download + SnackBar) options; imports playlist_picker_sheet and download_notifier
- `mobile/lib/features/player/full_player_sheet.dart` — Secondary controls row changed to MainAxisAlignment.spaceBetween; left-side Row added with playlist_add IconButton and _DownloadButton ConsumerWidget; _DownloadButton private class added at bottom of file with full 3-state logic

## Decisions Made

- TrackListTile changed from StatelessWidget to ConsumerWidget to watch downloadsProvider
- GestureDetector used for the download icon tap in the album art overlay instead of IconButton, to avoid layout constraint conflicts within the 48x48 SizedBox
- _DownloadButton extracted as a separate private ConsumerWidget in full_player_sheet.dart so only the button rebuilds on download progress updates, not the entire FullPlayerSheet

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. All three files analyzed clean with `flutter analyze` (no issues found).

## User Setup Required

None - no external service configuration required.

## Known Stubs

None. All download state is wired to the real `downloadsProvider` from Plan 01, and playlist adding is wired to the real `PlaylistPickerSheet` from Plan 02.

## Next Phase Readiness

- Download actions and visual indicators are accessible from search results (TrackListTile overlay + context menu) and full player screen (secondary controls)
- Plan 04 (Library screen) can use the same download overlay pattern for the downloads list
- `flutter analyze` passes clean across all modified files

---
*Phase: 04-library*
*Completed: 2026-03-27*
