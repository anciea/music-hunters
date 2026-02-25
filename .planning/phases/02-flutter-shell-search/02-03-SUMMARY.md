---
phase: 02-flutter-shell-search
plan: 03
subsystem: ui
tags: [flutter, riverpod, just_audio, mini-player, playback]

# Dependency graph
requires:
  - phase: 02-flutter-shell-search
    provides: AudioPlayer singleton provider, search screen with result tiles, app scaffold with NavigationBar
  - phase: 01-backend-api
    provides: /stream/{track_id} proxied streaming endpoint with X-API-Key auth
provides:
  - Tap-to-play on search result tiles via AudioSource.uri with X-API-Key header
  - currentTrackProvider (CurrentTrack Notifier, keepAlive) tracking active track in player_provider.dart
  - MiniPlayerBar widget: 64dp persistent bar above NavigationBar with album art, title, artist, play/pause
  - Play/pause toggle via StreamBuilder on player.playerStateStream
  - Error SnackBar on playback failure
affects: [phase-03-player]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AudioSource.uri with headers dict — required for just_audio to send custom headers (setUrl lacks headers param)"
    - "StreamBuilder<PlayerState> on player.playerStateStream for live play/pause state in UI"
    - "Riverpod @Riverpod(keepAlive: true) Notifier class for mutable singleton state (currentTrackProvider)"
    - "Column(Expanded + MiniPlayerBar) inside Scaffold body — mini player pinned above NavigationBar on all tabs"

key-files:
  created:
    - mobile/lib/shared/mini_player_bar.dart
  modified:
    - mobile/lib/core/providers/player_provider.dart
    - mobile/lib/core/providers/player_provider.g.dart
    - mobile/lib/features/search/search_screen.dart
    - mobile/lib/shared/app_scaffold.dart

key-decisions:
  - "Riverpod 3.x StateProvider not exported from flutter_riverpod — must use @Riverpod(keepAlive: true) Notifier class for mutable singleton state; StateProvider exists only in legacy.dart"
  - "AudioSource.uri mandatory for X-API-Key header injection — player.setUrl() convenience method has no headers parameter"
  - "player.stop() called before setAudioSource() to prevent concurrent playback collision on rapid taps"

patterns-established:
  - "Pattern: keepAlive Notifier for mutable app-lifetime state — avoids StateProvider (legacy in 3.x)"
  - "Pattern: MiniPlayerBar uses SizedBox.shrink() when currentTrackProvider is null — zero height, no layout cost"
  - "Pattern: player.playerStateStream via StreamBuilder for real-time play/pause icon state"

requirements-completed: [SRCH-03]

# Metrics
duration: 5min
completed: 2026-03-27
---

# Phase 02 Plan 03: Tap-to-Play and Mini Player Bar Summary

**just_audio AudioSource.uri tap-to-play from search results with persistent 64dp mini player bar above bottom NavigationBar**

## Performance

- **Duration:** 5 min
- **Started:** 2026-03-27T04:59:40Z
- **Completed:** 2026-03-27T05:04:00Z
- **Tasks:** 1 completed (Task 2 is checkpoint:human-verify — awaiting approval)
- **Files modified:** 5

## Accomplishments
- Wired tap-to-play in search result tiles using `AudioSource.uri` with `X-API-Key` header injection (avoids Pitfall 3 from RESEARCH.md — setUrl lacks headers support)
- Added `CurrentTrack` Riverpod Notifier (keepAlive) to player_provider.dart — provides `currentTrackProvider` tracking the active track for mini player display
- Created `MiniPlayerBar` ConsumerWidget: 64dp container above NavigationBar with album art, title, artist, and `StreamBuilder<PlayerState>` play/pause toggle
- Updated `AppScaffold` body to `Column(Expanded(navigationShell), MiniPlayerBar())` — mini player persists across all 4 tabs

## Task Commits

Each task was committed atomically:

1. **Task 1: Playback trigger on search result tap and mini player bar** - `0ee5d92` (feat)

**Plan metadata:** pending final docs commit

## Files Created/Modified
- `mobile/lib/shared/mini_player_bar.dart` — New: MiniPlayerBar ConsumerWidget with StreamBuilder play/pause, 64dp height, CachedNetworkImage album art
- `mobile/lib/core/providers/player_provider.dart` — Modified: Added CurrentTrack keepAlive Notifier with setTrack() method
- `mobile/lib/core/providers/player_provider.g.dart` — Modified: Regenerated with currentTrackProvider ($NotifierProvider<CurrentTrack, TrackDto?>)
- `mobile/lib/features/search/search_screen.dart` — Modified: Added _playTrack() using AudioSource.uri, player.stop(), currentTrackProvider.notifier.setTrack(), error SnackBar
- `mobile/lib/shared/app_scaffold.dart` — Modified: Body wrapped in Column with Expanded(navigationShell) + MiniPlayerBar()

## Decisions Made
- **StateProvider is legacy in Riverpod 3.x** — flutter_riverpod 3.3.1 does not export StateProvider from its main barrel. Used `@Riverpod(keepAlive: true)` Notifier class instead, which generates `currentTrackProvider` via build_runner.
- **AudioSource.uri mandatory** — `player.setUrl()` has no headers parameter; used `player.setAudioSource(AudioSource.uri(..., headers: {...}))` to inject X-API-Key.
- **player.stop() before setAudioSource()** — prevents concurrent playback collision on rapid successive taps.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] StateProvider not available in flutter_riverpod 3.x**
- **Found during:** Task 1 (implementing currentTrackProvider)
- **Issue:** Plan instructed `final currentTrackProvider = StateProvider<TrackDto?>((ref) => null)` but flutter_riverpod 3.3.1 does not export `StateProvider` (it's only in legacy.dart). Analyzer error: "The function 'StateProvider' isn't defined."
- **Fix:** Replaced with `@Riverpod(keepAlive: true) class CurrentTrack extends _$CurrentTrack` Notifier with `setTrack()` method; updated call sites to use `.notifier.setTrack(track)` instead of `.notifier.state = track`; ran `build_runner build --delete-conflicting-outputs` to regenerate.
- **Files modified:** player_provider.dart, player_provider.g.dart, search_screen.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0
- **Committed in:** 0ee5d92 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — bug: StateProvider removed from flutter_riverpod 3.x exports)
**Impact on plan:** Required approach change from StateProvider to Notifier class — same behavior, correct modern Riverpod 3.x idiom. No scope creep.

## Issues Encountered
- flutter_riverpod 3.3.1 dropped StateProvider from public exports — only available via `package:riverpod/legacy.dart`. Switched to Notifier class pattern which is the recommended Riverpod 3.x approach.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Search-to-play loop complete: search → tap result → audio streams from /stream/{track_id} → mini player bar appears with play/pause
- Task 2 (checkpoint:human-verify) awaits human end-to-end testing
- Phase 3 (full player) can extend currentTrackProvider and MiniPlayerBar into full-screen player

---
*Phase: 02-flutter-shell-search*
*Completed: 2026-03-27*
