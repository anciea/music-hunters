---
phase: 03-audio-playback
plan: 03
subsystem: ui
tags: [flutter, riverpod, just_audio, queue, reorder, long-press, context-menu]

# Dependency graph
requires:
  - phase: 03-audio-playback plan 01
    provides: QueueNotifier with playNow/playNext/addToQueue/removeAt/move, audioHandlerProvider
  - phase: 03-audio-playback plan 02
    provides: full_player_sheet.dart with queue button stub, TrackListTile base component
provides:
  - QueueBottomSheet widget with ReorderableListView for drag reorder and per-item remove
  - Long-press context menu on TrackListTile for Play Now / Play Next / Add to Queue
  - Full queue management UI flow from search result to queue display
affects:
  - 03-audio-playback plan 04 (downloads/library — queue UI is the shared playback entry point)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "QueueBottomSheet.show(context) static factory — encapsulates modal + DraggableScrollableSheet setup"
    - "StreamBuilder<int?> on currentIndexStream — drives currently-playing indicator without Riverpod coupling"
    - "onLongPress optional callback on TrackListTile — non-breaking extension, existing onTap preserved"

key-files:
  created:
    - mobile/lib/features/player/queue_bottom_sheet.dart
  modified:
    - mobile/lib/features/player/full_player_sheet.dart
    - mobile/lib/features/search/widgets/track_list_tile.dart
    - mobile/lib/features/search/search_screen.dart

key-decisions:
  - "QueueBottomSheet is a standalone file (not nested in full_player_sheet.dart) — keeps files focused, enables independent testing"
  - "currentIndexStream (StreamBuilder) used for playing indicator in queue — avoids adding another Riverpod provider for a simple int"
  - "onLongPress added as optional nullable param to TrackListTile — backward compatible, no forced migration of existing callers"
  - "Stub _QueueBottomSheet removed from full_player_sheet.dart — replaced by QueueBottomSheet.show(), reducing dead code"

patterns-established:
  - "Static .show() factory on ConsumerWidget for opening modal bottom sheets"
  - "Long-press context menu pattern: _showTrackContextMenu(context, track) in ConsumerStatefulWidget"

requirements-completed: [QUE-01, QUE-02, QUE-03, QUE-04]

# Metrics
duration: 5min
completed: 2026-03-27
---

# Phase 03 Plan 03: Queue Management UI Summary

**ReorderableListView queue bottom sheet with drag/remove controls and long-press context menu on search tiles wired to QueueNotifier**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-03-27T06:49:00Z
- **Completed:** 2026-03-27T06:54:41Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Created `QueueBottomSheet` ConsumerWidget with full ReorderableListView — shows queue tracks, currently-playing accent dot, drag reorder, and remove buttons
- Replaced `_QueueBottomSheet` stub in `full_player_sheet.dart` with `QueueBottomSheet.show(context)`, removing dead code
- Added `onLongPress` optional callback to `TrackListTile`, wired in `search_screen.dart` to open Play Now / Play Next / Add to Queue context menu

## Task Commits

Each task was committed atomically:

1. **Task 1: Queue bottom sheet with reorder and remove** - `2093415` (feat)
2. **Task 2: Long-press context menu on search result tiles** - `1d5558e` (feat)

## Files Created/Modified

- `mobile/lib/features/player/queue_bottom_sheet.dart` - New: QueueBottomSheet ConsumerWidget with ReorderableListView, currentIndexStream for playing indicator, removeAt/move calls
- `mobile/lib/features/player/full_player_sheet.dart` - Modified: import QueueBottomSheet, replace _openQueueSheet with QueueBottomSheet.show, remove _QueueBottomSheet stub
- `mobile/lib/features/search/widgets/track_list_tile.dart` - Modified: add optional onLongPress callback parameter
- `mobile/lib/features/search/search_screen.dart` - Modified: add _showTrackContextMenu with Play Now/Play Next/Add to Queue, wire onLongPress

## Decisions Made

- `QueueBottomSheet` extracted as a separate file rather than kept in `full_player_sheet.dart` — separation of concerns, plan explicitly specified the file path
- Used `StreamBuilder<int?>` on `handler.player.currentIndexStream` for the currently-playing dot indicator — simpler than a provider, already available from audioHandlerProvider
- `onLongPress` added as optional (nullable) param so existing TrackListTile callers are not broken

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

- `mobile/lib/` is gitignored by the Python project's `.gitignore` (line 17: `lib/`). Used `git add -f` to force-add new file, consistent with how all existing Dart files in this directory were committed.

## Next Phase Readiness

- Queue management UI is complete — users can build a queue from search results and manage it from the full player
- Plan 04 (local playlist management / downloads) can proceed — shared playback entry points (QueueNotifier, TrackListTile long-press) are stable

---
*Phase: 03-audio-playback*
*Completed: 2026-03-27*
