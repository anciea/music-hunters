---
phase: 02-flutter-shell-search
plan: 01
subsystem: ui
tags: [flutter, dart, riverpod, go_router, dio, retrofit, freezed, just_audio, android]

requires:
  - phase: 01-backend-api
    provides: TrackDTO and SearchResponse schema in api/models.py; /search endpoint

provides:
  - Flutter Android project in mobile/ with all dependencies resolved
  - Dark Material 3 theme (#121212 background, #1DB954 accent)
  - 4-tab bottom navigation shell with StatefulShellRoute state preservation
  - Dio singleton provider with X-API-Key interceptor
  - Retrofit MusicApi client with searchTracks GET /search
  - Freezed TrackDto and SearchResponse models matching backend schema exactly
  - keepAlive AudioPlayer provider for background audio
  - All build_runner-generated .g.dart and .freezed.dart files

affects:
  - 02-02 (search UI builds on MusicApi, SearchResponse, and SearchScreen placeholder)
  - 02-03 (mini player uses audioPlayerProvider from player_provider.dart)

tech-stack:
  added:
    - flutter_riverpod 3.3.1 (state management)
    - riverpod_annotation 4.0.2 + riverpod_generator 4.0.3 (code-gen providers)
    - go_router 17.1.0 (declarative routing with StatefulShellRoute)
    - dio 5.9.2 (HTTP client with interceptor chain)
    - retrofit 4.9.2 + retrofit_generator 10.2.3 (type-safe API client)
    - just_audio 0.10.5 (audio playback)
    - cached_network_image 3.4.1 (network image caching)
    - shimmer 3.0.0 (skeleton loading animation)
    - freezed 3.2.5 + freezed_annotation 3.1.0 (immutable data models)
    - json_annotation 4.11.0 + json_serializable 6.13.0 (JSON serialization)
    - build_runner 2.13.1 (Dart code generation runner)
  patterns:
    - "@riverpod functional provider with plain Ref parameter (Riverpod 4.x pattern)"
    - "@Riverpod(keepAlive: true) for AudioPlayer to survive navigation"
    - "abstract class with @freezed for immutable models (Freezed 3.x required)"
    - "StatefulShellRoute.indexedStack for persistent tab state in go_router 17.x"
    - "Dio InterceptorsWrapper.onRequest for X-API-Key header injection"
    - "--dart-define=API_BASE_URL and API_KEY for compile-time config"

key-files:
  created:
    - mobile/pubspec.yaml (all dependencies with corrected versions)
    - mobile/lib/main.dart (ProviderScope root)
    - mobile/lib/app.dart (MusicDlApp, dark theme, GoRouter)
    - mobile/lib/shared/app_scaffold.dart (NavigationBar shell)
    - mobile/lib/core/config/app_config.dart (dart-define config)
    - mobile/lib/core/api/dio_provider.dart (Dio + X-API-Key interceptor)
    - mobile/lib/core/api/music_api.dart (Retrofit MusicApi)
    - mobile/lib/core/models/track_dto.dart (Freezed TrackDto)
    - mobile/lib/core/models/search_response.dart (Freezed SearchResponse)
    - mobile/lib/core/providers/player_provider.dart (keepAlive AudioPlayer)
    - mobile/lib/features/search/search_screen.dart (placeholder)
    - mobile/lib/features/library/library_screen.dart (Coming soon)
    - mobile/lib/features/downloads/downloads_screen.dart (Coming soon)
    - mobile/lib/features/settings/settings_screen.dart (Coming soon)
  modified:
    - mobile/android/app/src/main/AndroidManifest.xml (INTERNET permission)
    - mobile/test/widget_test.dart (updated to use MusicDlApp)

key-decisions:
  - "Riverpod 4.x (riverpod_generator 4.0.3) uses plain Ref in functional providers — DioRef/MusicApiRef/AudioPlayerRef types no longer generated"
  - "Freezed 3.x requires abstract class keyword — without it, generated _$TrackDto mixin causes missing concrete implementation errors"
  - "freezed_annotation 3.2.5 does not exist on pub.dev — corrected to 3.1.0 (latest published)"
  - "riverpod_generator ^2.6.5 conflicts with riverpod_annotation ^4.0.2 — corrected to ^4.0.3 to match resolver output"

patterns-established:
  - "Pattern: Riverpod 4.x functional providers take plain Ref, not typed Ref subclasses"
  - "Pattern: Freezed 3.x models must be abstract class X with _$X"
  - "Pattern: Use flutter pub get --dry-run to verify dependencies before writing Dart code"

requirements-completed: [SRCH-01, SRCH-02, SRCH-03]

duration: 18min
completed: 2026-03-27
---

# Phase 02 Plan 01: Flutter Shell + Foundation Summary

**Flutter Android project scaffolded with Riverpod 4.x, go_router StatefulShellRoute, Dio+Retrofit API client, Freezed models matching backend TrackDTO, and keepAlive AudioPlayer — app compiles with 4-tab dark Material 3 navigation shell**

## Performance

- **Duration:** ~18 min
- **Started:** 2026-03-27T03:48:50Z
- **Completed:** 2026-03-27T04:06:30Z
- **Tasks:** 3
- **Files modified:** 16 (created 14, modified 2)

## Accomplishments

- Flutter project scaffolded in `mobile/` via `flutter create --project-name musicdl mobile` with all 108 dependencies resolved via `flutter pub get`
- Core Dart files created: AppConfig, Dio+Retrofit API client, Freezed models (TrackDto + SearchResponse), keepAlive AudioPlayer provider — all build_runner generated files produced successfully
- App shell with dark Material 3 theme (#121212 background, #1DB954 accent), 4-tab NavigationBar via `StatefulShellRoute.indexedStack`, and placeholder screens for all 4 routes — `flutter analyze --no-fatal-infos` exits 0

## Task Commits

Each task was committed atomically:

1. **Task 1: Flutter project scaffold, pubspec, AndroidManifest** - `86b8025` (feat)
2. **Task 2: Core Dart files — config, API, models, player** - `0a12c0e` (feat)
3. **Task 3: App shell with dark theme, go_router, 4-tab nav** - `7a2b2aa` (feat)

## Files Created/Modified

- `mobile/pubspec.yaml` - All dependencies with corrected pub.dev versions
- `mobile/android/app/src/main/AndroidManifest.xml` - INTERNET permission added
- `mobile/lib/main.dart` - ProviderScope root entry point
- `mobile/lib/app.dart` - MusicDlApp ConsumerWidget, dark theme, GoRouter config
- `mobile/lib/shared/app_scaffold.dart` - StatefulNavigationShell + NavigationBar
- `mobile/lib/core/config/app_config.dart` - Compile-time dart-define config
- `mobile/lib/core/api/dio_provider.dart` - Dio singleton + X-API-Key interceptor
- `mobile/lib/core/api/dio_provider.g.dart` - Generated by riverpod_generator 4.x
- `mobile/lib/core/api/music_api.dart` - Retrofit abstract class + musicApiProvider
- `mobile/lib/core/api/music_api.g.dart` - Generated by retrofit_generator
- `mobile/lib/core/models/track_dto.dart` - Freezed TrackDto (13 fields, snake_case JSON)
- `mobile/lib/core/models/track_dto.freezed.dart` - Generated by freezed
- `mobile/lib/core/models/track_dto.g.dart` - Generated by json_serializable
- `mobile/lib/core/models/search_response.dart` - Freezed SearchResponse
- `mobile/lib/core/models/search_response.freezed.dart` - Generated
- `mobile/lib/core/models/search_response.g.dart` - Generated
- `mobile/lib/core/providers/player_provider.dart` - keepAlive AudioPlayer provider
- `mobile/lib/core/providers/player_provider.g.dart` - Generated
- `mobile/lib/features/search/search_screen.dart` - Placeholder screen
- `mobile/lib/features/library/library_screen.dart` - Placeholder "Coming soon"
- `mobile/lib/features/downloads/downloads_screen.dart` - Placeholder "Coming soon"
- `mobile/lib/features/settings/settings_screen.dart` - Placeholder "Coming soon"
- `mobile/test/widget_test.dart` - Updated to use MusicDlApp

## Decisions Made

- Riverpod 4.x (riverpod_generator 4.0.3) uses plain `Ref` in functional providers — the typed `DioRef`/`MusicApiRef` pattern from Riverpod 3.x research is deprecated
- Freezed 3.x requires `abstract class TrackDto with _$TrackDto` — the `class` (non-abstract) variant causes missing concrete implementation errors
- `freezed_annotation ^3.2.5` doesn't exist on pub.dev; corrected to `^3.1.0`
- `riverpod_generator ^2.6.5` version constraint conflicts with `riverpod_annotation ^4.0.2`; corrected to `^4.0.3`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Package version corrections for pub.dev compatibility**
- **Found during:** Task 1 (flutter pub get)
- **Issue:** `freezed_annotation: ^3.2.5` does not exist; `riverpod_generator: ^2.6.5` conflicts with `riverpod_annotation: ^4.0.2`
- **Fix:** Corrected `freezed_annotation` to `^3.1.0` (actual latest); corrected `riverpod_generator` to `^4.0.3` (matched resolver output from test project)
- **Files modified:** mobile/pubspec.yaml
- **Verification:** `flutter pub get` succeeded, pubspec.lock generated
- **Committed in:** 86b8025 (Task 1 commit)

**2. [Rule 1 - Bug] Riverpod 4.x provider signature uses plain Ref**
- **Found during:** Task 2 (flutter analyze after build_runner)
- **Issue:** Generated `.g.dart` files use `Ref ref` not `DioRef ref` — research doc patterns are for Riverpod 3.x generators. `flutter analyze` reported 5 `undefined_class` errors.
- **Fix:** Changed all `@riverpod` functional provider signatures from `DioRef`/`MusicApiRef`/`AudioPlayerRef` to plain `Ref`
- **Files modified:** mobile/lib/core/api/dio_provider.dart, mobile/lib/core/api/music_api.dart, mobile/lib/core/providers/player_provider.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0
- **Committed in:** 0a12c0e (Task 2 commit)

**3. [Rule 1 - Bug] Freezed 3.x requires abstract class keyword**
- **Found during:** Task 2 (flutter analyze after build_runner)
- **Issue:** `class TrackDto with _$TrackDto` caused `Missing concrete implementations` errors for all freezed-generated abstract members. Freezed 3.x README explicitly requires `abstract class`.
- **Fix:** Added `abstract` keyword to both `TrackDto` and `SearchResponse` class declarations
- **Files modified:** mobile/lib/core/models/track_dto.dart, mobile/lib/core/models/search_response.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0
- **Committed in:** 0a12c0e (Task 2 commit)

**4. [Rule 1 - Bug] widget_test.dart referenced removed MyApp class**
- **Found during:** Task 3 (flutter analyze after rewriting main.dart)
- **Issue:** Scaffold-generated widget_test.dart imported `MyApp` which was replaced by `MusicDlApp`
- **Fix:** Updated test to use `MusicDlApp` wrapped in `ProviderScope`
- **Files modified:** mobile/test/widget_test.dart
- **Verification:** `flutter analyze --no-fatal-infos` exits 0
- **Committed in:** 7a2b2aa (Task 3 commit)

---

**Total deviations:** 4 auto-fixed (all Rule 1 - Bug)
**Impact on plan:** All fixes were necessary for correctness (API version changes between research date and execution, Riverpod 4.x breaking changes). No scope creep.

## Issues Encountered

The package versions listed in 02-RESEARCH.md were researched on 2026-03-27 but some do not match actual pub.dev state:
- `freezed_annotation 3.2.5` was listed but only `3.1.0` exists
- `riverpod_generator ^2.6.5` is incompatible with `riverpod_annotation ^4.0.2`
- Riverpod 4.x (riverpod_generator 4.0.3) changed functional provider signatures to use plain `Ref`

All resolved automatically. The probing technique (creating a test project with `any` version constraints) was effective for discovering actual available versions.

## Next Phase Readiness

- Flutter project compiles cleanly with `flutter analyze --no-fatal-infos` passing
- All .g.dart and .freezed.dart files generated and committed
- MusicApi.searchTracks and musicApiProvider ready for search UI to call
- audioPlayerProvider ready for playback implementation in Plan 02-03
- SearchScreen placeholder ready for Plan 02-02 full search implementation

## Self-Check: PASSED

- FOUND: mobile/lib/core/models/track_dto.g.dart
- FOUND: mobile/lib/core/api/music_api.g.dart
- FOUND: mobile/lib/shared/app_scaffold.dart
- FOUND: mobile/lib/app.dart
- FOUND: mobile/lib/main.dart
- FOUND: .planning/phases/02-flutter-shell-search/02-01-SUMMARY.md
- FOUND: commit 86b8025
- FOUND: commit 0a12c0e
- FOUND: commit 7a2b2aa

---
*Phase: 02-flutter-shell-search*
*Completed: 2026-03-27*
