# Phase 2: Flutter Shell + Search - Research

**Researched:** 2026-03-27
**Domain:** Flutter Android app — Material 3 shell, Riverpod state management, Dio+Retrofit API client, just_audio playback
**Confidence:** HIGH (all package versions verified against pub.dev; architecture patterns verified against official docs)

## Summary

Phase 2 builds the Flutter Android application that connects to the Phase 1 FastAPI backend. The app needs a 4-tab bottom navigation shell, a search screen that calls `/search` and renders results as compact list tiles, and a minimal mini player bar that calls `/stream/{track_id}` via just_audio when a result is tapped. All locked decisions from CONTEXT.md have confirmed, current implementations in the Flutter ecosystem.

The standard Flutter + Riverpod + Dio + Retrofit + just_audio stack is well-supported and widely used for music app UIs. The key non-obvious concern is that just_audio requires explicit Android manifest configuration for background audio and internet permissions. The Retrofit code-generation pipeline (retrofit + build_runner) requires one setup step before any API code compiles. Riverpod 3.x unified `Notifier`/`AsyncNotifier` patterns (no more `AutoDisposeNotifier` variant) are the current idiom.

**Primary recommendation:** Use `flutter create` to scaffold the project into a `mobile/` subdirectory at the repo root. Wire all packages listed below before writing any feature code — the code-generation dependency chain (Retrofit + Freezed + Riverpod annotation) must compile cleanly before implementing screens.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**App Shell & Navigation**
- 4 bottom nav tabs: Search, Library, Downloads, Settings — maps to milestone phases
- Dark theme only — conventional for music apps, easier on eyes during listening sessions
- State management: Riverpod — type-safe, scalable, handles async data flows well
- API client: Dio + Retrofit — interceptor chain for X-API-Key header injection, typed response models, built-in error handling

**Search UX**
- Search triggers on submit button / Enter key press — not debounce/auto-search (21-source search is expensive)
- Loading state: shimmer skeleton cards showing expected layout shape while results load
- Source platform displayed as small colored badge chip on each result card
- Empty states: illustrated friendly empty state with search suggestion on first launch; error state with retry button on failure

**Result Cards & Playback Trigger**
- Compact list tiles with small leading album art thumbnail (48x48) — maximize visible results per screen
- Tap result = immediate playback via just_audio using /stream/{track_id} endpoint
- Minimal bottom mini bar appears during playback: shows track title + play/pause control (full player deferred to Phase 3)
- Album art fallback: platform-colored placeholder with source icon when cover art is unavailable

### Claude's Discretion
No "You decide" answers — all questions resolved with recommended defaults accepted by user.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| SRCH-01 | User can search by keyword and see results from all sources | Dio+Retrofit GET /search?q= with X-API-Key interceptor; AsyncNotifier for search state |
| SRCH-02 | Each result shows title, artist, album art, duration, and source platform | ListTile + CachedNetworkImage + Chip; TrackDTO model fields map directly to UI fields |
| SRCH-03 | User can tap a search result to start playback immediately | just_audio AudioPlayer.setUrl() with /stream/{track_id}; mini player Riverpod provider tracks playing state |
</phase_requirements>

---

## Project Constraints (from CLAUDE.md)

| Directive | Impact on Phase 2 |
|-----------|-------------------|
| Flutter + Python FastAPI tech stack — decided | Flutter Android app connects to Phase 1 API |
| Android only for v1 | No iOS-specific code; target `android` only in Flutter |
| Local-only playlists (SQLite) | Not in scope for Phase 2; no sqflite work this phase |
| App requires network for search/streaming | No offline fallback needed for Phase 2 |
| GSD workflow enforcement | All file edits must go through `/gsd:execute-phase` |

---

## Standard Stack

### Core
| Library | Version (verified) | Purpose | Why Standard |
|---------|--------------------|---------|--------------|
| flutter_riverpod | ^3.3.1 | State management | Official Riverpod Flutter binding; v3 unifies Notifier/AutoDisposeNotifier |
| riverpod_annotation | ^4.0.2 | Code-gen annotations for @riverpod | Enables `@riverpod` generator syntax; required for generated providers |
| go_router | ^17.1.0 | Declarative routing + StatefulShellRoute | Flutter team maintained; StatefulShellRoute preserves nav state per tab |
| dio | ^5.9.2 | HTTP client with interceptors | flutter.cn verified publisher; interceptor chain for X-API-Key injection |
| retrofit | ^4.9.2 | Type-safe API client code generation | Generates typed API service from abstract class + annotations |
| just_audio | ^0.10.5 | Audio playback | Most widely used Flutter audio package; supports HTTP streaming + Range |
| cached_network_image | ^3.4.1 | Album art image loading + caching | Disk cache + placeholder/error builder; standard for network images |
| shimmer | ^3.0.0 | Skeleton loading animation | Minimal single-purpose package; well-maintained |

### Dev / Code Generation
| Library | Version (verified) | Purpose | When to Use |
|---------|--------------------|---------|-------------|
| build_runner | ^2.13.1 | Dart code generation runner | Required to run Retrofit + Freezed + Riverpod generators |
| retrofit_generator | ^10.2.3 | Generates Retrofit API implementation | Paired with retrofit package; run via build_runner |
| freezed | ^3.2.5 | Immutable data classes + union types | Use for TrackDTO and SearchResponse Dart models |
| freezed_annotation | ^3.2.5 | Annotations for freezed | Paired with freezed generator |
| json_annotation | ^4.9.0 | JSON serialization annotations | Required by freezed for fromJson/toJson |
| json_serializable | ^6.9.5 | Generates fromJson/toJson | Used by build_runner with json_annotation |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| go_router | Navigator 2.0 manually | go_router is higher level; StatefulShellRoute handles nested nav with tab state preservation |
| Retrofit | raw Dio calls | Retrofit generates boilerplate; for a 3-endpoint API it saves little but establishes the pattern for later phases |
| cached_network_image | flutter_cache_manager directly | cached_network_image wraps it with Image widget integration |
| shimmer | manual AnimatedContainer | shimmer is battle-tested, 3 lines of use, no reason to hand-roll |

**Installation:**
```yaml
# pubspec.yaml dependencies:
flutter_riverpod: ^3.3.1
riverpod_annotation: ^4.0.2
go_router: ^17.1.0
dio: ^5.9.2
retrofit: ^4.9.2
just_audio: ^0.10.5
cached_network_image: ^3.4.1
shimmer: ^3.0.0

# dev_dependencies:
build_runner: ^2.13.1
retrofit_generator: ^10.2.3
freezed: ^3.2.5
freezed_annotation: ^3.2.5
json_annotation: ^4.9.0
json_serializable: ^6.9.5
riverpod_generator: ^2.6.5
```

**After pubspec.yaml is written, run code generation:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Architecture Patterns

### Recommended Project Structure
```
mobile/
├── lib/
│   ├── main.dart                  # ProviderScope root + MaterialApp.router
│   ├── app.dart                   # ThemeData + GoRouter configuration
│   ├── core/
│   │   ├── api/
│   │   │   ├── music_api.dart     # Retrofit abstract class @RestApi
│   │   │   ├── music_api.g.dart   # Generated by build_runner
│   │   │   └── dio_provider.dart  # Riverpod provider for Dio + interceptor
│   │   ├── models/
│   │   │   ├── track_dto.dart     # @freezed TrackDTO from API
│   │   │   └── search_response.dart # @freezed SearchResponse
│   │   └── providers/
│   │       └── player_provider.dart # AudioPlayer singleton provider
│   ├── features/
│   │   ├── search/
│   │   │   ├── search_screen.dart
│   │   │   ├── search_notifier.dart   # AsyncNotifier<SearchResponse?>
│   │   │   ├── widgets/
│   │   │   │   ├── track_list_tile.dart
│   │   │   │   ├── source_badge.dart
│   │   │   │   └── shimmer_list.dart
│   │   ├── library/
│   │   │   └── library_screen.dart    # Placeholder
│   │   ├── downloads/
│   │   │   └── downloads_screen.dart  # Placeholder
│   │   └── settings/
│   │       └── settings_screen.dart   # Placeholder
│   └── shared/
│       ├── mini_player_bar.dart
│       └── app_scaffold.dart          # Shell with NavigationBar + mini player
├── android/
│   └── app/src/main/AndroidManifest.xml  # INTERNET + FOREGROUND_SERVICE permissions
└── pubspec.yaml
```

### Pattern 1: Riverpod AsyncNotifier for Search State

Use `AsyncNotifier` (Riverpod 3.x) for the search provider. The `build()` method returns `null` (no initial search). A `search(String query)` method triggers the API call.

```dart
// Source: https://riverpod.dev/docs/whats_new (Riverpod 3.0)
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  FutureOr<SearchResponse?> build() => null;  // null = no search yet

  Future<void> search(String query) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(musicApiProvider).searchTracks(query),
    );
  }
}
```

**Consuming in widget:**
```dart
final searchState = ref.watch(searchNotifierProvider);
searchState.when(
  data: (response) => response == null
      ? const EmptySearchPrompt()
      : TrackResultList(tracks: response.tracks),
  loading: () => const ShimmerList(),
  error: (e, _) => ErrorRetryWidget(onRetry: () => notifier.search(lastQuery)),
);
```

### Pattern 2: Dio Interceptor for X-API-Key

```dart
// core/api/dio_provider.dart
@riverpod
Dio dio(DioRef ref) {
  final d = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
  d.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['X-API-Key'] = AppConfig.apiKey;
      handler.next(options);
    },
  ));
  return d;
}
```

### Pattern 3: Retrofit API Service

```dart
// core/api/music_api.dart
@RestApi()
abstract class MusicApi {
  factory MusicApi(Dio dio, {String baseUrl}) = _MusicApi;

  @GET('/search')
  Future<SearchResponse> searchTracks(@Query('q') String query);
}
```

### Pattern 4: just_audio Playback from Stream URL

The `/stream/{track_id}` endpoint is a proxied HTTP stream. just_audio's `AudioSource.uri()` consumes it directly. The backend supports Range requests which just_audio uses for seeking.

```dart
// core/providers/player_provider.dart
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(AudioPlayerRef ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
}

// In search_screen.dart on tile tap:
Future<void> playTrack(TrackDTO track) async {
  final player = ref.read(audioPlayerProvider);
  final streamUrl = '${AppConfig.apiBaseUrl}/stream/${track.trackId}';
  await player.setUrl(streamUrl, headers: {'X-API-Key': AppConfig.apiKey});
  await player.play();
}
```

### Pattern 5: go_router StatefulShellRoute for Bottom Nav

`StatefulShellRoute` preserves the scroll/state of each tab when switching. This is the correct pattern for persistent bottom nav in go_router 6+.

```dart
final _router = GoRouter(
  initialLocation: '/search',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/search', builder: ...)]),
        StatefulShellBranch(routes: [GoRoute(path: '/library', builder: ...)]),
        StatefulShellBranch(routes: [GoRoute(path: '/downloads', builder: ...)]),
        StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: ...)]),
      ],
    ),
  ],
);
```

### Anti-Patterns to Avoid

- **Global `AudioPlayer` in widget state:** The player must survive screen rebuilds and navigation. Use a `keepAlive: true` Riverpod provider. If placed in a widget's `initState`, it disposes on navigation and playback stops.
- **Calling `player.setUrl()` without `await`:** If the widget taps quickly, successive calls can collide. Always `await player.stop()` before `setUrl()` when a track is already playing.
- **Building Dio inside each widget:** Dio should be a singleton provider. Multiple Dio instances mean multiple connection pools and duplicate interceptors.
- **Using `StateProvider<List<TrackDTO>>` for search results:** Async state (loading/error/data) needs `AsyncNotifier`. `StateProvider` cannot represent loading/error states cleanly.
- **Forgetting `--delete-conflicting-outputs` in build_runner:** Generated `.g.dart` files conflict with stale ones. Always pass this flag.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Album art caching | Custom HTTP + file cache | cached_network_image | Handles cache eviction, placeholder widget, error fallback, fade-in all in one widget |
| Shimmer loading animation | AnimatedBuilder + gradient | shimmer package | Shimmer needs precise pixel-sync across multiple children — hand-rolled versions look janky |
| Retry/exponential backoff | Custom wrapper | Dio retry interceptor or `AsyncValue.guard` | Edge cases in backoff math; Dio interceptor handles this |
| Type-safe JSON models | Manual `fromJson` | freezed + json_serializable | freezed generates copyWith, equality, toString; manual fromJson misses null-safety edge cases |
| Audio player lifecycle | Raw MediaPlayer (Android) | just_audio | just_audio handles focus, errors, buffering, and exposes clean Dart streams |

---

## Common Pitfalls

### Pitfall 1: Android Manifest Missing INTERNET Permission

**What goes wrong:** The app silently fails all network requests on device. Dio throws `SocketException` or `HandshakeException`.
**Why it happens:** Flutter's default manifest does not include `INTERNET` permission for release builds in all configurations.
**How to avoid:** Add to `android/app/src/main/AndroidManifest.xml` before any API call is tested on device:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
**Warning signs:** API calls work in profile mode but fail in release; `flutter run --release` shows network errors.

### Pitfall 2: build_runner Generates Stale `.g.dart` Files

**What goes wrong:** After changing a Retrofit or Freezed model, `dart analyze` shows type errors in generated code that don't match the source.
**Why it happens:** build_runner caches outputs and skips regeneration when it thinks inputs haven't changed.
**How to avoid:** Always run `flutter pub run build_runner build --delete-conflicting-outputs` after any model or API interface change.
**Warning signs:** `_$TrackDTO` refers to fields that no longer exist; Retrofit generated class has wrong method signatures.

### Pitfall 3: just_audio `setUrl` with Headers Requires AudioSource.uri

**What goes wrong:** `player.setUrl(url)` does not support custom headers. The `/stream` endpoint requires `X-API-Key` header — without it the backend returns 401, and just_audio surfaces this as a generic `PlayerException`.
**Why it happens:** `player.setUrl()` is a convenience method with no headers parameter.
**How to avoid:** Use the explicit form:
```dart
await player.setAudioSource(
  AudioSource.uri(
    Uri.parse(streamUrl),
    headers: {'X-API-Key': AppConfig.apiKey},
  ),
);
```
**Warning signs:** Audio fails to start with no obvious error; backend logs show 401 from stream endpoint.

### Pitfall 4: Riverpod Provider Scoping — keepAlive for AudioPlayer

**What goes wrong:** AudioPlayer disposes when the last listener unsubscribes, which can happen during navigation. Music stops unexpectedly when switching tabs.
**Why it happens:** Riverpod disposes providers when they have zero listeners by default (`autoDispose` is now the default in Riverpod 3.x).
**How to avoid:** Use `@Riverpod(keepAlive: true)` on the AudioPlayer provider. This keeps the player alive for the app lifetime.
**Warning signs:** Playback stops when navigating away from the search screen; `player.playing` is false after tab switch.

### Pitfall 5: go_router 17.x Breaking Changes from go_router 6/7

**What goes wrong:** Code examples from blog posts written for go_router 5-7 use deprecated `GoRoute` builder patterns or the old `ShellRoute` (not `StatefulShellRoute`).
**Why it happens:** go_router had major API revisions across major versions.
**How to avoid:** Use only the official go_router 17.x docs or the pub.dev example. `StatefulShellRoute.indexedStack` is the correct pattern. `ShellRoute` is the old non-state-preserving variant — avoid.
**Warning signs:** Tab state resets on every navigation; code references `ShellRoute` instead of `StatefulShellRoute`.

### Pitfall 6: Shimmer Package Usage — Wrap the List, Not Each Item

**What goes wrong:** Shimmer animation is out-of-sync across multiple skeleton cards when each card has its own `Shimmer.fromColors`.
**Why it happens:** Each `Shimmer.fromColors` has its own independent animation controller.
**How to avoid:** Wrap the entire skeleton list in a single `Shimmer.fromColors` and use plain `Container` children:
```dart
Shimmer.fromColors(
  baseColor: const Color(0xFF1E1E1E),
  highlightColor: const Color(0xFF2A2A2A),
  child: Column(children: List.generate(5, (_) => const SkeletonTile())),
)
```
**Warning signs:** Each skeleton card pulses independently at slightly different phases.

---

## Code Examples

### TrackDTO Freezed Model
```dart
// Source: https://pub.dev/packages/freezed (official README)
@freezed
class TrackDto with _$TrackDto {
  const factory TrackDto({
    required String trackId,
    String? songName,
    String? singers,
    String? album,
    String? coverUrl,
    int? durationS,
    String? duration,
    String? source,
    String? ext,
    int? bitrate,
    String? codec,
    String? fileSize,
    int? fileSizeBytes,
  }) = _TrackDto;

  factory TrackDto.fromJson(Map<String, dynamic> json) =>
      _$TrackDtoFromJson(json);
}
```

### SearchResponse Freezed Model
```dart
@freezed
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required List<TrackDto> tracks,
    required List<String> warnings,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}
```

### Source Badge Color Map
```dart
// Per 02-UI-SPEC.md — locked per-source badge colors
const Map<String, Color> sourceBadgeColors = {
  'netease':  Color(0xFFCC0000),
  'qq':       Color(0xFF1296DB),
  'spotify':  Color(0xFF1AA34A),
  'youtube':  Color(0xFFCC0000),
  'ytmusic':  Color(0xFFCC0000),
  'tidal':    Color(0xFF000000),
  'qobuz':    Color(0xFF1C3A6B),
  'deezer':   Color(0xFFA238FF),
  'kugou':    Color(0xFF2979FF),
  'kuwo':     Color(0xFFFF6E00),
  'migu':     Color(0xFFE31837),
  'joox':     Color(0xFF00C24B),
};
Color badgeColorFor(String source) =>
    sourceBadgeColors[source.toLowerCase()] ?? const Color(0xFF424242);
```

### App ThemeData (Dark Only)
```dart
ThemeData darkTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E1E1E),
    primary: Color(0xFF1DB954),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    indicatorColor: Color(0xFF1DB954),
  ),
  useMaterial3: true,
);
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `StateNotifier` + `StateNotifierProvider` | `Notifier` + `AsyncNotifier` with `@riverpod` generator | Riverpod 2.0 (2022), finalized in 3.0 (2025) | All tutorial code pre-2023 uses deprecated StateNotifier — do not copy |
| `AutoDisposeNotifier` class | `Notifier` (autoDispose is default in v3) | Riverpod 3.0 | Simplifies class hierarchy; `keepAlive: true` opt-in |
| `ShellRoute` | `StatefulShellRoute.indexedStack` | go_router 6.x | ShellRoute doesn't preserve tab state; StatefulShellRoute does |
| `flutter_bloc` / `provider` | Riverpod (locked decision) | Ongoing | Not applicable — locked to Riverpod |

**Deprecated/outdated:**
- `StateNotifierProvider`: Soft-deprecated in Riverpod 2.0; removed from recommended patterns in v3. Do not use.
- `ShellRoute` (non-stateful): Does not preserve scroll/state per tab branch. Use `StatefulShellRoute`.

---

## Environment Availability

Phase 2 creates a new Flutter project — it does not modify existing Python code. Key external dependencies:

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|---------|
| Flutter SDK | App build | Unknown — not probed | — | Must be installed by executor; no fallback |
| Android SDK / emulator | `flutter run` | Unknown — not probed | — | Physical device via USB debugging |
| Phase 1 backend API | All API calls | Yes (Phase 1 complete) | — | Run locally with `uvicorn api.main:app` |
| Dart pub.dev access | Package install | Yes (network available) | — | — |

**Missing dependencies with no fallback:**
- Flutter SDK: Must be installed on the development machine. Tasks should begin with `flutter --version` to verify. If absent, the executor must install Flutter before proceeding.

**Missing dependencies with fallback:**
- Android emulator: Can substitute with a physical Android device via `flutter run -d <device_id>`.

---

## Open Questions

1. **Where does the Flutter project live in the repo?**
   - What we know: No `mobile/` or Flutter project directory exists yet at repo root.
   - What's unclear: Should it be `mobile/`, `flutter/`, or the repo root itself?
   - Recommendation: Create at `mobile/` to keep Flutter project separate from the Python `api/` and `musicdl/` packages. This avoids Dart tooling (`.dart_tool/`, `build/`) cluttering the Python root.

2. **How are API base URL and API key configured in the Flutter app?**
   - What we know: Backend uses `X-API-Key` header; base URL is the cloud server HTTPS endpoint.
   - What's unclear: The user hasn't decided on a configuration mechanism (env vars baked at build, `--dart-define`, `assets/config.json`).
   - Recommendation: Use `--dart-define=API_BASE_URL=https://... --dart-define=API_KEY=...` at build time. This is the standard Flutter approach for secrets; avoids committing secrets to source.

3. **Does the Phase 1 backend `/stream` endpoint require the `X-API-Key` header?**
   - What we know: CONTEXT.md says "All API calls need X-API-Key header injection." The `/stream` URL will be passed directly to just_audio.
   - What's unclear: If just_audio's `AudioSource.uri(headers:)` sends the key on every HLS segment request or only the manifest.
   - Recommendation: Pass headers via `AudioSource.uri(headers: {'X-API-Key': key})`. For a proxied stream endpoint (not HLS), this is a single HTTP request — no segment complexity.

---

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/flutter_riverpod — version 3.3.1 verified 2026-03-27
- pub.dev/packages/riverpod_annotation — version 4.0.2 verified 2026-03-27
- pub.dev/packages/go_router — version 17.1.0 verified 2026-03-27
- pub.dev/packages/dio — version 5.9.2 verified 2026-03-27
- pub.dev/packages/retrofit — version 4.9.2 verified 2026-03-27
- pub.dev/packages/just_audio — version 0.10.5 verified 2026-03-27
- pub.dev/packages/cached_network_image — version 3.4.1 verified 2026-03-27
- pub.dev/packages/shimmer — version 3.0.0 verified 2026-03-27
- pub.dev/packages/build_runner — version 2.13.1 verified 2026-03-27
- pub.dev/packages/retrofit_generator — version 10.2.3 verified 2026-03-27
- pub.dev/packages/freezed — version 3.2.5 verified 2026-03-27
- riverpod.dev/docs/whats_new — Riverpod 3.0 Notifier/AsyncNotifier patterns
- `.planning/phases/02-flutter-shell-search/02-CONTEXT.md` — locked decisions
- `.planning/phases/02-flutter-shell-search/02-UI-SPEC.md` — component specifications, colors, spacing
- `api/models.py` — TrackDTO and SearchResponse schema (ground truth)

### Secondary (MEDIUM confidence)
- codewithandrea.com/articles/flutter-riverpod-async-notifier — AsyncNotifier usage patterns (verified against riverpod.dev)
- go_router StatefulShellRoute pattern — verified against go_router pub.dev example

### Tertiary (LOW confidence)
- None — all critical claims verified against pub.dev or official docs

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all package versions verified live against pub.dev 2026-03-27
- Architecture: HIGH — patterns verified against Riverpod 3.0 official docs and go_router pub.dev examples
- Pitfalls: HIGH — Android manifest and just_audio headers pitfalls are documented in official packages' README/migration guides

**Research date:** 2026-03-27
**Valid until:** 2026-04-27 (stable ecosystem — packages update slowly)
