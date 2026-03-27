# Phase 3: Audio Playback - Research

**Researched:** 2026-03-27
**Domain:** Flutter audio playback — audio_service + just_audio + Riverpod queue management
**Confidence:** HIGH

## Summary

Phase 3 builds the full audio playback experience on top of Phase 2's existing `just_audio` singleton and `mini_player_bar.dart`. The critical architectural decision — already locked in STATE.md — is that `audio_service` must wrap the existing `just_audio` AudioPlayer from the start. This cannot be retrofitted.

The `audio_service` package provides the Android `MediaSessionService` glue: it creates a foreground service that keeps audio alive when the app is backgrounded, registers the Android notification with MediaStyle controls, and routes media button events (headset, Bluetooth). `audio_session` handles audio focus — pausing on phone call, ducking for notifications. These two packages work together and neither overlaps with `just_audio`'s domain.

The queue is a Riverpod `@Riverpod(keepAlive: true)` notifier wrapping `just_audio`'s `ConcatenatingAudioSource`. All shuffle/repeat state lives in the same notifier. The full player UI is a `DraggableScrollableSheet` overlay (not a route push), consistent with the locked CONTEXT.md decision.

**Primary recommendation:** Wrap the existing `AudioPlayer` singleton in a `BaseAudioHandler` subclass, expose it through a Riverpod provider, and keep `ConcatenatingAudioSource` as the single source of truth for queue order.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Full Player Screen Design**
- Full-width dominant album art (~300dp centered, Spotify-style)
- Solid dark background (#121212) — no blur, no performance overhead
- Slide-up bottom sheet (DraggableScrollableSheet) for mini-to-full player transition — no route push
- Source badge + quality info (format/bitrate when available) shown on full player

**Queue Management UX**
- Queue accessed via icon button on full player that opens a bottom sheet list
- Long-press context menu on search result tiles for "Play Next" / "Add to Queue"
- Single track playback only — user taps one track, it plays. No auto-fill from search results
- Memory-only queue (Riverpod state) — lost on app kill. SQLite persistence deferred

**Playback Behavior**
- Stop after last track in queue when not repeating
- Auto-retry stream once on failure, then show error SnackBar with "Retry" action
- Live preview timestamp while scrubbing seek bar — shows position label above thumb during drag
- MediaStyle notification with large album art + play/pause, skip prev, skip next

### Claude's Discretion
No "You decide" answers — all questions resolved with recommended defaults accepted by user.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| PLAY-01 | User can play/pause a track from any screen | audio_service handler exposes play/pause; mini player bar and full player both call handler methods |
| PLAY-02 | User can see and scrub a seek bar with current position and total duration | just_audio `positionStream` + `durationStream`; Slider widget with onChangeEnd calling `handler.seek()` |
| PLAY-03 | User can skip to next/previous track in the queue | `ConcatenatingAudioSource` + handler `skipToNext()`/`skipToPrevious()` |
| PLAY-04 | User can toggle shuffle mode on/off | just_audio `setShuffleModeEnabled()` + queue notifier shuffle state |
| PLAY-05 | User can cycle repeat mode (off / one / all) | just_audio `setLoopMode(LoopMode.off/one/all)` |
| PLAY-06 | Audio continues playing when app is backgrounded | audio_service `AudioServiceBackground` foreground service — Android foreground service required |
| PLAY-07 | Android notification bar shows playback controls | audio_service `MediaItem` + `PlaybackState` → Android MediaStyle notification auto-generated |
| PLAY-08 | Headset button controls supported | audio_service routes media button events to handler automatically |
| PLAY-09 | Audio focus managed correctly | audio_session `AudioSession.instance.configure()` with `AudioSessionConfiguration.music()` |
| MINI-01 | Persistent mini player bar visible at bottom of all screens | Existing `app_scaffold.dart` already has mini player in Column above NavigationBar |
| MINI-02 | Mini player shows current track title, artist, and play/pause control | Existing `mini_player_bar.dart` — needs progress line and loading indicator added |
| MINI-03 | Tapping mini player expands to full-screen player view | Wrap mini player in GestureDetector; show DraggableScrollableSheet overlay |
| QUE-01 | User can view the current playback queue | Queue bottom sheet triggered from full player queue icon |
| QUE-02 | User can add a track to the queue | Long-press context menu on TrackListTile → queue notifier `add()` |
| QUE-03 | User can remove a track from the queue | Queue bottom sheet close button → queue notifier `removeAt()` |
| QUE-04 | User can reorder tracks in the queue | ReorderableListView in queue sheet → queue notifier `move()` → ConcatenatingAudioSource `move()` |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| audio_service | 0.18.18 | AudioHandler base class, Android MediaSession, foreground service, notification controls | The Flutter standard for background audio; integrates with just_audio |
| audio_session | 0.2.3 | Audio focus management — pause on call, duck for notifications | Companion to audio_service; handles Android AudioFocusRequest |
| just_audio | 0.10.5 | Audio decoding, streaming, ConcatenatingAudioSource queue | Already installed in Phase 2 |
| flutter_riverpod | ^3.3.1 | State management for queue, current track, shuffle/repeat | Already installed; keepAlive providers survive navigation |
| riverpod_annotation | ^4.0.2 | Code-generation for @riverpod providers | Already installed |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| cached_network_image | ^3.4.1 | Album art in full player | Already installed |
| freezed_annotation | ^3.1.0 | Immutable queue state model | Already installed |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| audio_service | just_audio_background | just_audio_background is simpler but less flexible; audio_service is the correct choice for full MediaSession control per STATE.md decision |
| ConcatenatingAudioSource | Manual URL swapping | ConcatenatingAudioSource is atomic and handles gapless; manual swapping breaks skip |

**Installation (new packages only):**
```bash
flutter pub add audio_service audio_session
```

**Verified versions (pub.dev, 2026-03-27):**
- audio_service: 0.18.18
- audio_session: 0.2.3
- just_audio: 0.10.5 (already installed, matches pub.dev latest)

---

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── core/
│   ├── audio/
│   │   ├── audio_handler.dart        # MusicDlAudioHandler extends BaseAudioHandler
│   │   ├── audio_handler.g.dart      # generated
│   │   └── queue_notifier.dart       # QueueNotifier — wraps ConcatenatingAudioSource
│   ├── providers/
│   │   └── player_provider.dart      # existing — add audioHandlerProvider
│   └── models/
│       └── track_dto.dart            # existing — unchanged
├── features/
│   ├── player/
│   │   ├── full_player_sheet.dart    # DraggableScrollableSheet overlay
│   │   └── queue_bottom_sheet.dart   # ReorderableListView queue UI
│   └── search/
│       ├── search_screen.dart        # existing — add long-press context menu
│       └── widgets/
│           └── track_list_tile.dart  # existing — add GestureDetector long-press
└── shared/
    └── mini_player_bar.dart          # existing — add tap, progress line, loading spinner
```

### Pattern 1: AudioHandler Wrapping just_audio
**What:** Subclass `BaseAudioHandler` from `audio_service`. Inject the existing `AudioPlayer` singleton. Delegate all playback calls to it. Override `play()`, `pause()`, `seek()`, `skipToNext()`, `skipToPrevious()`, `setShuffleMode()`, `setRepeatMode()`. Broadcast `PlaybackState` and `mediaItem` so the notification updates automatically.

**When to use:** Always — required for background audio and notification controls.

**Example:**
```dart
// Source: audio_service 0.18.x official API
class MusicDlAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;

  MusicDlAudioHandler(this._player) {
    // Forward just_audio state → audio_service PlaybackState stream
    _player.playbackEventStream.listen(_broadcastPlaybackState);
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value != null && index < queue.value!.length) {
        mediaItem.add(queue.value![index]);
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _player.setLoopMode({
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
    }[repeatMode]!);
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }
}
```

### Pattern 2: AudioService Initialization in main.dart
**What:** `AudioService.init()` must be called in `main()` before `runApp()`. It starts the foreground service and returns the handler instance.

**When to use:** Always — required Android entry point for background audio.

**Example:**
```dart
// Source: audio_service 0.18.x README
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // audio_session: configure for music (audio focus, interruptions)
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // audio_service: initialize handler, returns the MusicDlAudioHandler
  final audioHandler = await AudioService.init(
    builder: () {
      // Get the existing just_audio singleton — requires ProviderContainer trick
      // OR: pass player directly here. Simplest: create player here, share via provider.
      return MusicDlAudioHandler(AudioPlayer());
    },
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.musicdl.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false, // keep notification when paused
    ),
  );

  runApp(ProviderScope(
    overrides: [
      audioHandlerProvider.overrideWithValue(audioHandler),
    ],
    child: const MusicDlApp(),
  ));
}
```

### Pattern 3: Queue Notifier with ConcatenatingAudioSource
**What:** A `keepAlive` Riverpod notifier that owns both the Dart-side queue list (`List<TrackDto>`) and the `ConcatenatingAudioSource`. Mutations go through the notifier; the notifier keeps both in sync atomically.

**When to use:** All queue operations — add, remove, reorder, play now.

**Example:**
```dart
@Riverpod(keepAlive: true)
class Queue extends _$Queue {
  late ConcatenatingAudioSource _audioSource;

  @override
  List<TrackDto> build() {
    _audioSource = ConcatenatingAudioSource(children: []);
    return [];
  }

  ConcatenatingAudioSource get audioSource => _audioSource;

  Future<void> playNow(TrackDto track, MusicDlAudioHandler handler) async {
    state = [track];
    await _audioSource.clear();
    await _audioSource.add(_toAudioSource(track));
    await handler.skipToQueueItem(0);
    await handler.play();
  }

  Future<void> playNext(TrackDto track) async {
    final insertIndex = (ref.read(audioHandlerProvider).playbackState.value.queueIndex ?? 0) + 1;
    state = [...state]..insert(insertIndex, track);
    await _audioSource.insert(insertIndex, _toAudioSource(track));
  }

  Future<void> addToQueue(TrackDto track) async {
    state = [...state, track];
    await _audioSource.add(_toAudioSource(track));
  }

  Future<void> removeAt(int index) async {
    state = [...state]..removeAt(index);
    await _audioSource.removeAt(index);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    await _audioSource.move(oldIndex, newIndex);
  }

  AudioSource _toAudioSource(TrackDto track) {
    final streamUrl = '${AppConfig.baseUrl}/stream?track_id=${track.trackId}&source=${track.source}';
    return AudioSource.uri(
      Uri.parse(streamUrl),
      headers: {'X-API-Key': AppConfig.apiKey},
      tag: MediaItem(
        id: '${track.source}_${track.trackId}',
        title: track.songName ?? 'Unknown',
        artist: track.singers,
        album: track.album,
        artUri: track.coverUrl != null ? Uri.parse(track.coverUrl!) : null,
        duration: track.durationS != null ? Duration(seconds: track.durationS!.round()) : null,
      ),
    );
  }
}
```

### Pattern 4: DraggableScrollableSheet Full Player Overlay
**What:** The full player is not a route. It's shown via a `showModalBottomSheet` with `isScrollControlled: true` and a `DraggableScrollableSheet` child with `initialChildSize: 1.0`. This keeps the NavigationBar and mini player bar underneath (under the sheet's opaque background).

**When to use:** When mini player bar is tapped.

**Example:**
```dart
void _openFullPlayer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.0,
      maxChildSize: 1.0,
      builder: (context, scrollController) => const FullPlayerSheet(),
    ),
  );
}
```

### Pattern 5: Auto-Retry with Error SnackBar
**What:** Listen to `just_audio`'s `processingState` stream. When `ProcessingState.completed` or error occurs, attempt `player.seek(Duration.zero)` and `player.play()` once. If it fails again, show SnackBar.

**When to use:** In the audio handler's stream subscription, not in UI code.

```dart
int _retryCount = 0;

void _handlePlayerError(Object error) async {
  if (_retryCount < 1) {
    _retryCount++;
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (_) {
      _notifyError();
    }
  } else {
    _retryCount = 0;
    _notifyError();
  }
}
```

### Anti-Patterns to Avoid
- **Creating AudioPlayer in widget tree:** AudioPlayer must be a singleton; creating per-widget causes resource leaks and concurrent playback
- **Calling just_audio directly from UI:** All playback calls must go through the AudioHandler so the notification stays in sync
- **Retrofitting audio_service after playback works:** Impossible without complete rewrite — the AudioHandler IS the player controller from day one
- **Using pushNamed for full player:** The full player must be a DraggableScrollableSheet overlay, not a route, so the bottom nav persists underneath
- **Building MediaItem outside _toAudioSource:** AudioSource tag must be set at creation time for notification art to work

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Android foreground service for audio | Custom Service + AIDL | audio_service AudioHandler | Foreground service lifecycle, wake locks, and notification binding are 500+ lines of Android boilerplate |
| Audio focus (phone call pause) | AudioManager direct calls | audio_session `configure()` | AudioFocusRequest API is complex; audio_session handles all interruption types |
| Notification media controls | NotificationCompat.Builder | audio_service (auto-generated via PlaybackState) | MediaStyle notification requires Android MediaSession callback wiring |
| Seek bar position display | Manual timer polling | just_audio `positionStream` | `positionStream` updates every ~200ms with accurate position; polling is inaccurate and wastes CPU |
| Queue sync between UI and player | Custom List + manual AudioSource management | ConcatenatingAudioSource | Handles index tracking, gapless buffering, and concurrent modification safety |

---

## Common Pitfalls

### Pitfall 1: AudioHandler Not Registered Before runApp
**What goes wrong:** `AudioService.init()` called after `runApp()` → MediaSession not registered → background audio and notifications don't work
**Why it happens:** Treating audio_service like a regular package that can be initialized lazily
**How to avoid:** Always call `AudioService.init()` in `main()` before `runApp()`. Pass handler via `ProviderScope` overrides.
**Warning signs:** Audio plays in foreground but stops when home button pressed

### Pitfall 2: Notification Album Art Not Loading
**What goes wrong:** Notification shows placeholder icon instead of album art
**Why it happens:** `MediaItem.artUri` must be an HTTPS URI accessible from the Android system (not a local file). Also, `artHeaders` parameter is not supported in MediaStyle — the system fetches art without auth headers.
**How to avoid:** Use CachedNetworkImage URLs directly (public CDN URLs via the backend proxy). The backend `/stream` proxy ensures CDN URLs are accessible.
**Warning signs:** Album art shows in app but not in notification

### Pitfall 3: ConcatenatingAudioSource Not Set Before Play
**What goes wrong:** `player.setAudioSource()` must be called with the `ConcatenatingAudioSource` before first play. If called after, the player has no source and `play()` is a no-op.
**Why it happens:** Developer initializes queue notifier lazily; player never receives the source
**How to avoid:** In `AudioHandler` constructor, immediately call `_player.setAudioSource(_concatenatingSource)`. Queue notifier adds/removes from the same `ConcatenatingAudioSource` instance.
**Warning signs:** `player.play()` does nothing; `processingState` stays `idle`

### Pitfall 4: Riverpod Provider Order — Handler vs Player
**What goes wrong:** `audioHandlerProvider` and `audioPlayerProvider` provide different objects; widgets that call `player.play()` directly bypass the handler → notification goes out of sync
**Why it happens:** Phase 2 used `audioPlayerProvider` directly; Phase 3 must route through handler
**How to avoid:** Remove direct `audioPlayerProvider` usage from all UI code. UI calls `ref.read(audioHandlerProvider).play()`. Only the handler internally touches `_player`.
**Warning signs:** Notification shows "paused" while audio plays, or vice versa

### Pitfall 5: Seek Bar SliderTheme Overlay Label
**What goes wrong:** Live position label above seek bar thumb during drag is complex to implement and often flickers or mispositions
**Why it happens:** Flutter's `Slider` doesn't have a built-in overlay label; `SliderTheme.showValueIndicator` shows a tooltip but only for discrete sliders
**How to avoid:** Use a `Stack` with a `ValueListenableBuilder` that positions a `Text` widget above the thumb during drag (track via `onChangeStart`/`onChanged`/`onChangeEnd`). Reset position label visibility on `onChangeEnd`.
**Warning signs:** Label appears at wrong position or flickers

### Pitfall 6: Android Manifest Missing Service Declaration
**What goes wrong:** App crashes on start with `MissingPluginException` or background audio silently fails
**Why it happens:** `audio_service` requires explicit `<service>` declaration in `AndroidManifest.xml`
**How to avoid:** Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>
<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>
```
**Warning signs:** Crash on first `AudioService.init()` call

### Pitfall 7: audio_session Must Configure Before AudioService.init
**What goes wrong:** Audio focus not requested; app audio is interrupted by other apps without pausing
**Why it happens:** `AudioSession.configure()` called after `AudioService.init()` — too late
**How to avoid:** Call `AudioSession.instance.configure()` before `AudioService.init()` in `main()`
**Warning signs:** Phone call doesn't pause music; notification music keeps playing over phone

### Pitfall 8: ReorderableListView Index Off-by-One on Remove
**What goes wrong:** Removing a queue item after reorder removes the wrong item
**Why it happens:** `ReorderableListView.onReorder` gives new indices; if a remove happens before `move()` completes, indices are stale
**How to avoid:** All queue mutations go through `QueueNotifier` which is the single source of truth. Never read index from `ConcatenatingAudioSource.length` — always use `state.length`.
**Warning signs:** Wrong track removed; queue list and audio source desync

---

## Code Examples

### Seek Bar with Live Timestamp Label
```dart
// Source: Flutter Slider widget + ValueNotifier pattern
class SeekBar extends ConsumerStatefulWidget { ... }

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragPosition; // non-null while dragging

  @override
  Widget build(BuildContext context) {
    final player = ref.read(audioPlayerProvider);
    return StreamBuilder<PositionData>(
      stream: Rx.combineLatest2(
        player.positionStream,
        player.durationStream,
        (pos, dur) => PositionData(pos, dur ?? Duration.zero),
      ),
      builder: (context, snapshot) {
        final data = snapshot.data ?? PositionData(Duration.zero, Duration.zero);
        final progress = data.duration.inMilliseconds > 0
            ? (_dragPosition ?? data.position.inMilliseconds.toDouble())
            : 0.0;

        return Column(children: [
          // Position label above thumb during drag (only visible while dragging)
          if (_dragPosition != null)
            Align(
              alignment: Alignment(
                (progress / data.duration.inMilliseconds) * 2 - 1,
                0,
              ),
              child: Text(_formatDuration(Duration(milliseconds: progress.round())),
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
            ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1DB954),
              inactiveTrackColor: const Color(0xFF424242),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: progress.clamp(0, data.duration.inMilliseconds.toDouble()),
              max: data.duration.inMilliseconds.toDouble(),
              onChangeStart: (_) => setState(() => _dragPosition = progress),
              onChanged: (v) => setState(() => _dragPosition = v),
              onChangeEnd: (v) {
                setState(() => _dragPosition = null);
                ref.read(audioHandlerProvider).seek(Duration(milliseconds: v.round()));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(data.position), style: ...),
              Text(_formatDuration(data.duration), style: ...),
            ],
          ),
        ]);
      },
    );
  }
}
```

### Long-Press Context Menu on TrackListTile
```dart
// Add to existing TrackListTile widget
GestureDetector(
  onLongPress: () => _showTrackContextMenu(context, ref, track),
  child: existingListTile,
)

void _showTrackContextMenu(BuildContext context, WidgetRef ref, TrackDto track) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(
        leading: const Icon(Icons.play_arrow, color: Color(0xFF9E9E9E)),
        title: const Text('Play Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onTap: () {
          Navigator.pop(context);
          ref.read(queueProvider.notifier).playNow(track, ref.read(audioHandlerProvider));
        },
      ),
      ListTile(
        leading: const Icon(Icons.playlist_play, color: Color(0xFF9E9E9E)),
        title: const Text('Play Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onTap: () {
          Navigator.pop(context);
          ref.read(queueProvider.notifier).playNext(track);
        },
      ),
      ListTile(
        leading: const Icon(Icons.add_to_queue, color: Color(0xFF9E9E9E)),
        title: const Text('Add to Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onTap: () {
          Navigator.pop(context);
          ref.read(queueProvider.notifier).addToQueue(track);
        },
      ),
    ]),
  );
}
```

### Mini Player Progress Line
```dart
// Add to mini_player_bar.dart — pinned at bottom of 64dp Container
StreamBuilder<Duration?>(
  stream: player.durationStream,
  builder: (context, durationSnapshot) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, positionSnapshot) {
        final duration = durationSnapshot.data;
        final position = positionSnapshot.data ?? Duration.zero;
        final progress = (duration != null && duration.inMilliseconds > 0)
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;
        return LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: const Color(0xFF2A2A2A),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF1DB954)),
          minHeight: 2,
        );
      },
    );
  },
),
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `just_audio_background` (simpler wrapper) | `audio_service` full handler | audio_service 0.18.x | More boilerplate but full control over notification, MediaSession, and queue |
| `AudioService.start()` static method | `AudioService.init()` returning handler | audio_service 0.18 | Handler is now a typed Dart object, not a global static — cleaner Riverpod integration |
| Manual `MediaSession` in Kotlin | `audio_service` Android plugin | Current | Eliminates ~300 lines of platform channel code |

**Deprecated/outdated:**
- `AudioService.start()`: Replaced by `AudioService.init()` in 0.18.x — do not use
- `AudioServiceBackground` static class: Removed in 0.18.x — all operations through handler instance now
- `just_audio_background`: Still maintained but `audio_service` is the correct choice when full control needed

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All mobile code | UNKNOWN — see STATE.md blocker | — | Must install before any Phase 3 execution |
| audio_service | PLAY-06, PLAY-07, PLAY-08, PLAY-09 | Not yet in pubspec | 0.18.18 (pub.dev verified) | None — required |
| audio_session | PLAY-09 | Not yet in pubspec | 0.2.3 (pub.dev verified) | None — required |
| just_audio | Streaming | ✓ in pubspec | 0.10.5 | — |
| Android emulator/device | Testing | UNKNOWN | — | Physical device acceptable |

**Missing dependencies with no fallback:**
- Flutter SDK installation — blocking all Phase 3 execution (known blocker from STATE.md)
- audio_service and audio_session — must be added to pubspec.yaml in Wave 0

**Missing dependencies with fallback:**
- None

---

## Open Questions

1. **Flutter SDK installation status**
   - What we know: STATE.md records Flutter SDK as BLOCKING since Phase 02-01
   - What's unclear: Whether Flutter has been installed since that blocker was recorded
   - Recommendation: Wave 0 task must verify `flutter --version` before any other work. If missing, plan step must halt with install instructions.

2. **AudioPlayer singleton sharing between AudioHandler and existing providers**
   - What we know: Phase 2 created `audioPlayerProvider` as a Riverpod keepAlive provider; Phase 3 AudioHandler needs the same AudioPlayer instance
   - What's unclear: Whether to pass the AudioPlayer into the handler at init time (via `ProviderScope` override) or let the handler create its own player
   - Recommendation: Create AudioPlayer in `main()` before `AudioService.init()`, pass to handler constructor, override both `audioPlayerProvider` and `audioHandlerProvider` in `ProviderScope`. This gives all providers the same player instance.

3. **Notification album art headers**
   - What we know: The backend `/stream` endpoint requires `X-API-Key` header; Android system fetches notification art without custom headers
   - What's unclear: Whether `MediaItem.artUri` needs to be a public URL or if album art (coverUrl) is fetched from a public CDN directly
   - Recommendation: Use `track.coverUrl` directly for `MediaItem.artUri` — cover images are public CDN URLs from the music platforms (not behind the API key). The API key is only needed for the audio stream itself.

---

## Project Constraints (from CLAUDE.md)

- Tech stack: Flutter (frontend) + Python FastAPI (backend) — locked
- Platform: Android only for v1
- Storage: Local-only (SQLite) — queue persistence deferred to future phase
- State management: Riverpod with code generation (@riverpod annotation, .g.dart files)
- Dark theme: #121212 background, #1E1E1E surfaces, #1DB954 accent — locked
- Naming: Snake_case files, PascalCase classes, @Riverpod(keepAlive: true) for singletons
- GSD workflow: All file changes through GSD commands

---

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/audio_service — version 0.18.18 verified 2026-03-27, API patterns from README
- pub.dev/packages/audio_session — version 0.2.3 verified 2026-03-27
- pub.dev/packages/just_audio — version 0.10.5 verified 2026-03-27
- Existing codebase: `player_provider.dart`, `mini_player_bar.dart`, `pubspec.yaml` — direct read

### Secondary (MEDIUM confidence)
- audio_service 0.18.x migration guide — `AudioService.init()` pattern, handler instance model
- Flutter Material 3 DraggableScrollableSheet documentation — overlay pattern

### Tertiary (LOW confidence)
- None

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — pub.dev versions verified directly
- Architecture: HIGH — based on existing codebase read + audio_service 0.18.x API patterns
- Pitfalls: HIGH — based on direct codebase analysis + known audio_service breaking changes
- Environment: MEDIUM — Flutter SDK install status unknown (blocker from STATE.md)

**Research date:** 2026-03-27
**Valid until:** 2026-05-27 (audio_service/audio_session are stable; just_audio 0.10.x is current)
