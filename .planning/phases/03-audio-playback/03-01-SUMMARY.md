---
phase: 03-audio-playback
plan: 01
subsystem: audio
tags: [audio_service, just_audio, audio_session, riverpod, android, background-audio, media-notification]

# Dependency graph
requires:
  - phase: 02-flutter-shell-search
    provides: AudioPlayer singleton via audioPlayerProvider, CurrentTrack notifier, TrackDto model
provides:
  - MusicDlAudioHandler (BaseAudioHandler + SeekHandler wrapping just_audio AudioPlayer)
  - QueueNotifier (keepAlive Riverpod notifier managing List<TrackDto> + player playlist)
  - AudioService.init + AudioSession.configure initialization in main.dart
  - Android manifest declarations for foreground service and media button receiver
  - audioHandlerProvider (overridable via ProviderScope.overrides)
  - queueProvider with playNow/playNext/addToQueue/removeAt/move operations
affects:
  - 03-02 (player UI reads handler.player streams for position/duration, watches playbackState)
  - 03-03 (search screen calls queueProvider.notifier.playNow(track))
  - 03-04 (queue management screen uses queueProvider state for ReorderableListView)

# Tech tracking
tech-stack:
  added:
    - audio_service 0.18.18 (background audio + OS media notification)
    - audio_session 0.2.3 (audio focus configuration for music playback)
  patterns:
    - Handler injection pattern: AudioService.init creates handler before runApp, injected via ProviderScope.overrideWithValue
    - Tag-based mediaItem: MediaItem attached as tag on each AudioSource; read from player.sequence[index].tag
    - Playlist mutation via player methods: addAudioSource/insertAudioSource/removeAudioSourceAt/moveAudioSource (not ConcatenatingAudioSource)

key-files:
  created:
    - mobile/lib/core/audio/audio_handler.dart
    - mobile/lib/core/audio/queue_notifier.dart
    - mobile/lib/core/audio/queue_notifier.g.dart
  modified:
    - mobile/pubspec.yaml
    - mobile/pubspec.lock
    - mobile/android/app/src/main/AndroidManifest.xml
    - mobile/lib/core/providers/player_provider.dart
    - mobile/lib/core/providers/player_provider.g.dart
    - mobile/lib/main.dart

key-decisions:
  - "Use player.sequence[index].tag pattern (not queue.value[index]) — BaseAudioHandler.queue BehaviorSubject is never populated"
  - "just_audio 0.10.x deprecated ConcatenatingAudioSource — use player.addAudioSource/insertAudioSource/etc. directly"
  - "AudioServiceConfig assertion: androidNotificationOngoing=true is incompatible with androidStopForegroundOnPause=false — use only androidStopForegroundOnPause: false"
  - "audioHandlerProvider uses overrideWithValue pattern because AudioService.init must complete before ProviderScope mounts"

patterns-established:
  - "Handler injection: create handler before ProviderScope, inject via overrideWithValue — never create in provider body"
  - "Playlist mutation: all queue changes go through QueueNotifier; notifier keeps List<TrackDto> state in sync with player playlist"
  - "MediaItem as tag: attach MediaItem as tag when building AudioSource.uri; handler reads it on index change for notification"

requirements-completed: [PLAY-01, PLAY-06, PLAY-07, PLAY-08, PLAY-09]

# Metrics
duration: 10min
completed: 2026-03-27
---

# Phase 03 Plan 01: Audio Service Foundation Summary

**audio_service + just_audio integration with background playback, OS notification controls, and queue management via Riverpod notifier**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-03-27T06:26:31Z
- **Completed:** 2026-03-27T06:35:46Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- MusicDlAudioHandler wraps just_audio AudioPlayer and bridges to audio_service for background playback and Android media notification with prev/play-pause/next controls
- QueueNotifier (keepAlive Riverpod) manages List<TrackDto> state in lock-step with player internal playlist via playNow/playNext/addToQueue/removeAt/move
- main.dart initializes audio_session (music focus) then AudioService.init before runApp; handler injected via ProviderScope.overrideWithValue

## Task Commits

Each task was committed atomically:

1. **Task 1: Add audio_service + audio_session packages and update AndroidManifest** - `64b4fab` (feat)
2. **Task 2: Create AudioHandler and update main.dart initialization** - `8b00f4a` (feat)
3. **Task 3: Create QueueNotifier and run build_runner** - `db00d55` (feat)
4. **Type fix: properly type audioPlayer provider as AudioPlayer** - `dcbd7fe` (fix)

**Plan metadata:** (docs commit — see below)

## Files Created/Modified

- `mobile/lib/core/audio/audio_handler.dart` - MusicDlAudioHandler extending BaseAudioHandler; bridges PlaybackEvent to PlaybackState for OS notification; tag-based mediaItem on index changes
- `mobile/lib/core/audio/queue_notifier.dart` - Queue Riverpod notifier with playNow/playNext/addToQueue/removeAt/move; _toAudioSource builds AudioSource.uri with X-API-Key header and MediaItem tag
- `mobile/lib/core/audio/queue_notifier.g.dart` - Generated Riverpod code for Queue notifier
- `mobile/lib/core/providers/player_provider.dart` - Added audioHandlerProvider (overridable), updated audioPlayerProvider to return AudioPlayer (typed)
- `mobile/lib/core/providers/player_provider.g.dart` - Regenerated with audioHandlerProvider + typed AudioPlayer
- `mobile/lib/main.dart` - AudioSession.configure + AudioService.init + ProviderScope overrides before runApp
- `mobile/pubspec.yaml` - Added audio_service ^0.18.18 and audio_session dependencies
- `mobile/android/app/src/main/AndroidManifest.xml` - FOREGROUND_SERVICE permissions + AudioService + MediaButtonReceiver declarations

## Decisions Made

- **Tag-based mediaItem (not queue.value):** `BaseAudioHandler.queue` BehaviorSubject is never populated by audio_service — reading from `player.sequence[index].tag` is the only correct approach
- **ConcatenatingAudioSource deprecated:** just_audio 0.10.x removed public ConcatenatingAudioSource usage; all playlist mutations go through player methods directly
- **AudioServiceConfig assertion:** `androidNotificationOngoing=true` + `androidStopForegroundOnPause=false` is an invalid combination (audio_service asserts against it) — use only `androidStopForegroundOnPause: false` which achieves the goal of keeping service alive when paused
- **Handler injection pattern:** AudioService.init returns a typed handler; injected before ProviderScope via overrideWithValue so all keepAlive providers share the same instance

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] ConcatenatingAudioSource deprecated in just_audio 0.10.5**
- **Found during:** Task 2 (AudioHandler creation)
- **Issue:** Plan spec referenced `ConcatenatingAudioSource` which is deprecated in just_audio 0.10.x with warning `Use AudioPlayer.setAudioSources instead`. Flutter analyzer produced deprecation infos causing `--no-fatal-infos` verify to fail.
- **Fix:** Rewrote audio_handler.dart to use `player.setAudioSources([])` for init and expose `player` directly; QueueNotifier uses `player.addAudioSource/insertAudioSource/removeAudioSourceAt/moveAudioSource` instead of ConcatenatingAudioSource methods. The `_concatenatingSource.sequence[index].tag` pattern became `player.sequence[index].tag` — semantically identical.
- **Files modified:** mobile/lib/core/audio/audio_handler.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0 with no issues
- **Committed in:** 8b00f4a (Task 2 commit)

**2. [Rule 1 - Bug] AudioServiceConfig const assertion violation**
- **Found during:** Task 2 (main.dart initialization)
- **Issue:** `const AudioServiceConfig(androidNotificationOngoing: true, androidStopForegroundOnPause: false)` throws `const_eval_throws_exception` because audio_service asserts `!androidNotificationOngoing || androidStopForegroundOnPause`
- **Fix:** Removed `androidNotificationOngoing: true` — `androidStopForegroundOnPause: false` already achieves the goal (service stays in foreground during pause)
- **Files modified:** mobile/lib/main.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0 with no issues
- **Committed in:** 8b00f4a (Task 2 commit)

**3. [Rule 2 - Missing Critical] audioPlayer provider typed as dynamic**
- **Found during:** Task 2 (player_provider.dart update)
- **Issue:** Without `import 'package:just_audio/just_audio.dart'`, the `audioPlayer` function return type defaulted to `dynamic`, causing generated code to use `$FunctionalProvider<dynamic, dynamic, dynamic>` — unsafe for all callers
- **Fix:** Added just_audio import and explicit `AudioPlayer` return type; regenerated provider
- **Files modified:** mobile/lib/core/providers/player_provider.dart, player_provider.g.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0
- **Committed in:** dcbd7fe (separate fix commit)

---

**Total deviations:** 3 auto-fixed (2 bugs, 1 missing critical)
**Impact on plan:** All fixes required for correctness and type safety. The ConcatenatingAudioSource replacement is equivalent functionality using the current API. No scope creep.

## Issues Encountered

- git add rejected `mobile/lib/*` files due to root `.gitignore` having `lib/` pattern (Python build artifact rule). Used `git add -f` since files are already tracked. This pre-existing issue is out of scope but worth noting for future plans.

## Next Phase Readiness

- Audio infrastructure is fully wired: handler exists, queue notifier exists, initialization is correct
- Plans 03-02 and 03-03 can call `ref.read(queueProvider.notifier).playNow(track)` from search screen
- Plan 03-02 player UI can access `ref.read(audioHandlerProvider).player` for position/duration streams and `ref.watch(playbackState)` for play/pause state
- No blockers — `flutter analyze --no-fatal-infos` passes with zero issues

---
*Phase: 03-audio-playback*
*Completed: 2026-03-27*
