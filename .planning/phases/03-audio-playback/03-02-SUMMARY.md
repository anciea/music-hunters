---
phase: 03-audio-playback
plan: 02
subsystem: player-ui
tags: [flutter, player, seek-bar, mini-player, audio-service, just-audio, riverpod]

# Dependency graph
requires:
  - phase: 03-01
    provides: MusicDlAudioHandler, QueueNotifier, audioHandlerProvider, queueProvider
  - phase: 02
    provides: TrackDto model, SourceBadge widget, CachedNetworkImage, currentTrackProvider
provides:
  - FullPlayerSheet (DraggableScrollableSheet full-screen player overlay)
  - SeekBar widget with live drag timestamp and seek via audioHandlerProvider
  - Enhanced MiniPlayerBar with tap-to-expand, progress line, loading spinner
  - Search screen _playTrack delegated to queueProvider.notifier.playNow
affects:
  - 03-03 (queue management screen opened from FullPlayerSheet queue button)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Nested StreamBuilders pattern: outer on durationStream, inner on positionStream — avoids rxdart while listening to both streams
    - _dragPosition state in ConsumerStatefulWidget: persists across StreamBuilder rebuilds because it lives in State object, not stream data
    - DraggableScrollableSheet full-screen modal: initialChildSize 1.0, minChildSize 0.0 — swipe-to-dismiss with zero boilerplate
    - Stack + Positioned for progress line: LinearProgressIndicator pinned at bottom of Container via Positioned(bottom: 0)

key-files:
  created:
    - mobile/lib/features/player/full_player_sheet.dart
    - mobile/lib/features/player/seek_bar.dart
  modified:
    - mobile/lib/shared/mini_player_bar.dart
    - mobile/lib/features/search/search_screen.dart

key-decisions:
  - "Semantics with dynamic label cannot use const — removed const from Semantics wrapper, kept const on child SizedBox (apply to both full_player_sheet and mini_player_bar)"
  - "loopModeStream drives repeat button state (not a one-time read) — StreamBuilder on handler.player.loopModeStream enables reactive repeat UI"
  - "sequenceStateStream used for prev/next enabled state — provides both sequence length and currentIndex atomically"

requirements-completed: [PLAY-02, PLAY-03, PLAY-04, PLAY-05, MINI-01, MINI-02, MINI-03]

# Metrics
duration: 4min
completed: 2026-03-27
---

# Phase 03 Plan 02: Player UI and Mini Player Enhancement Summary

**Full player DraggableScrollableSheet with seek bar, shuffle/repeat/skip controls all via AudioHandler; mini player tap-to-expand, progress line, loading spinner; search screen playback via QueueNotifier.playNow**

## Performance

- **Duration:** ~4 min
- **Started:** 2026-03-27T06:43:47Z
- **Completed:** 2026-03-27T06:47:55Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- SeekBar ConsumerStatefulWidget uses nested StreamBuilders (no rxdart) on durationStream/positionStream; _dragPosition state preserved across rebuilds; onChangeEnd calls audioHandlerProvider.seek
- FullPlayerSheet: 300dp album art, track title/artist, SeekBar, shuffle/prev/play-pause/next/repeat all wired to audioHandlerProvider; loading state shows CircularProgressIndicator; queue button opens stub sheet (full queue UI in Plan 03-03)
- MiniPlayerBar enhanced: GestureDetector wrapping opens FullPlayerSheet via DraggableScrollableSheet; 2dp LinearProgressIndicator at bar bottom driven by positionStream/durationStream; play/pause replaced by CircularProgressIndicator when buffering/loading; play/pause calls handler.pause()/handler.play() via audioHandlerProvider
- search_screen._playTrack replaced: direct AudioPlayer.setAudioSource call removed, replaced with ref.read(queueProvider.notifier).playNow(track)

## Task Commits

Each task was committed atomically:

1. **Task 1: Full player sheet with seek bar and all playback controls** - `58d64fc` (feat)
2. **Task 2: Enhance mini player bar and refactor search screen playback** - `830a790` (feat)

## Files Created/Modified

- `mobile/lib/features/player/seek_bar.dart` — SeekBar ConsumerStatefulWidget; nested StreamBuilders; _dragPosition for live timestamp; _formatDuration helper; seeks via audioHandlerProvider on drag end
- `mobile/lib/features/player/full_player_sheet.dart` — FullPlayerSheet ConsumerWidget; 300dp CachedNetworkImage album art; SeekBar; 5-button main controls row; queue button with stub sheet; all playback through audioHandlerProvider
- `mobile/lib/shared/mini_player_bar.dart` — GestureDetector tap-to-expand; Stack+Positioned LinearProgressIndicator at bottom; StreamBuilder loading spinner; play/pause via handler not direct player
- `mobile/lib/features/search/search_screen.dart` — _playTrack refactored to queueProvider.notifier.playNow; removed all direct AudioPlayer/AudioSource.uri/AppConfig/audioPlayerProvider imports

## Decisions Made

- **Semantics const restriction:** Semantics with a string `label` parameter cannot be `const` in Flutter — removed `const` from Semantics wrappers; kept `const` on child SizedBox widgets to preserve performance
- **loopModeStream for repeat button:** StreamBuilder on handler.player.loopModeStream ensures the repeat icon reacts to mode changes from all sources (OS controls, programmatic)
- **sequenceStateStream for skip buttons:** Provides currentIndex and sequence atomically so prev/next enabled state is always consistent

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `const Semantics(label: ...)` is not valid when label contains string literal (flutter const constraint)**
- **Found during:** Task 1 (full_player_sheet.dart), Task 2 (mini_player_bar.dart)
- **Issue:** `const Semantics(label: 'Loading audio', child: SizedBox(...CircularProgressIndicator...))` fails with `const_with_non_const` because `CircularProgressIndicator(color: Color(...))` is not a const constructor in Flutter's current version
- **Fix:** Removed `const` from the `Semantics` wrapper and from the outer `Padding`; kept `const` on the child `SizedBox` widget to preserve as much compile-time const as possible
- **Files modified:** mobile/lib/features/player/full_player_sheet.dart, mobile/lib/shared/mini_player_bar.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0

**2. [Rule 2 - Missing Critical] seek_bar.dart imported just_audio unused**
- **Found during:** Task 1 verification
- **Issue:** `import 'package:just_audio/just_audio.dart'` was added but not used in seek_bar (all stream types inferred); caused `unused_import` warning
- **Fix:** Removed the unused import
- **Files modified:** mobile/lib/features/player/seek_bar.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0

None beyond the two const and import fixes above — plan executed accurately.

## Known Stubs

- `_QueueBottomSheet` in `full_player_sheet.dart` (line ~310): placeholder queue sheet with empty-state UI only. The `scrollController` parameter is accepted but unused. Full queue ReorderableListView and queue item rendering is deferred to Plan 03-03.

This stub is **intentional** — the queue button is functional (opens sheet), the sheet shows correct empty-state copy, and Plan 03-03 will replace `_QueueBottomSheet` with the full queue screen. The plan objective (full player controls, seek bar, mini player enhancement) is fully achieved.

---
*Phase: 03-audio-playback*
*Completed: 2026-03-27*
