# Project Research Summary

**Project:** MusicDL Mobile — Flutter Android app + Python FastAPI backend
**Domain:** Mobile music player with multi-source streaming and offline playback
**Researched:** 2026-03-26
**Confidence:** MEDIUM-HIGH overall

## Executive Summary

MusicDL Mobile is a personal music streaming and download app that wraps an existing Python `musicdl` library (21 sources, HLS/DRM support, metadata tagging) into a Flutter Android app via a FastAPI adapter backend. The core architectural insight is that the Python library is not rewritten — it is wrapped. The FastAPI layer is a pure adapter: it accepts REST requests from the Flutter client, delegates to synchronous `MusicClient` calls via `asyncio.run_in_executor`, and returns clean JSON DTOs that hide internal implementation details. The Flutter app owns all UI, local persistence (SQLite), and audio playback state.

The recommended approach is to build the backend FastAPI wrapper first (exposing `/search`, `/stream`, `/download` routes), then validate the full API-to-UI loop with a working search screen before investing in the most complex component: background audio playback. The audio stack (`just_audio` + `audio_service`) requires Android foreground service setup and must be integrated from the start of the playback phase — it cannot be retrofitted later without restructuring the entire audio architecture.

The two highest-risk technical decisions are the streaming architecture (proxy vs URL passthrough) and background audio setup. Both must be decided before implementation begins. Streaming URL expiry, Android Scoped Storage, and blocking the FastAPI event loop are failure modes that cause silent breakage in production that is hard to reproduce in development. These are addressed by design choices made in Phase 1 (proxy pattern) and Phase 3 (audio_service from day one), not by fixing bugs later.

---

## Key Findings

### Recommended Stack

The backend is Python 3.11+ with FastAPI 0.135.x (current stable as of March 2026) running on Uvicorn. FastAPI's native `StreamingResponse` handles audio proxying; `run_in_executor` bridges the synchronous `MusicClient` to the async event loop. No database, task queue (Celery), or OAuth is needed on the backend — it is stateless and single-user. A static API key via `APIKeyHeader` is sufficient security.

The Flutter frontend uses Flutter 3.41.x (stable) with Material 3 as the default design language. Riverpod 2.x handles state management (preferred over Provider for async-heavy apps). go_router handles navigation. dio handles HTTP (interceptors for global API key injection). just_audio + audio_service handle playback. sqflite + path_provider handle local persistence. Code generation (freezed + json_serializable + build_runner) handles immutable Dart models.

**Core technologies:**
- **FastAPI 0.135.x**: HTTP API framework — native async, SSE, auto OpenAPI docs, Pydantic v2 validation
- **asyncio.run_in_executor**: Bridges synchronous musicdl code into async FastAPI context — required pattern, no exceptions
- **Flutter 3.41.x + Material 3**: App framework — Android-first, iOS expansion path without rewrite
- **Riverpod 2.x**: State management — compile-safe, async-native (`AsyncValue`), no BuildContext dependency
- **just_audio + audio_service**: Audio playback — ExoPlayer-backed, background playback, MediaSession notification controls
- **sqflite + path_provider**: Local SQLite — official Flutter recommendation, simple schema does not require an ORM
- **dio**: HTTP client — interceptors eliminate manual API key injection on every call
- **go_router ^14.x**: Navigation — Flutter team recommendation for multi-screen apps

### Expected Features

The backend already handles multi-source search, download, format conversion, metadata tagging, HLS, and DRM. The Flutter app's primary work is UI, audio playback, and local data management.

**Must have (table stakes):**
- Play / Pause, seek bar, skip next/prev, shuffle, repeat modes — universal playback controls
- Background playback with Android notification controls and lock screen — mobile users expect this always
- Keyword search with results showing title, artist, album, cover art, source indicator
- Local playlist create / add / remove / reorder / delete — core library management
- Download to device + offline playback — the app's primary value proposition
- Mini player persistent at bottom of every screen — standard pattern (Spotify, YT Music, Apple Music)

**Should have (differentiators):**
- Audio format / quality badge per result (MP3 / FLAC / lossless) — audiophile value not available in any consumer app
- Filter search results by source or format — surface lossless results specifically
- Source indicator per search result — users know which of 21 platforms a track comes from
- Search history and recently played — reduce friction for repeat queries
- Download status indicator per track (downloaded / downloading / not downloaded)

**Defer to future milestone:**
- Lyrics display — backend embeds LRC at download time; display layer is deferred
- Playlist URL import — backend parses playlist URLs; UX design is complex, defer
- Source fallback on stream error — requires multi-result grouping, high complexity
- Audio casting (Chromecast) — requires Cast SDK, not core
- Equalizer / audio effects — platform complexity; just_audio does not support EQ directly

### Architecture Approach

The system is a classic client-server mobile architecture where the Python `musicdl` library is the backend brain and Flutter is the mobile UI layer. The backend has two layers: a FastAPI routes layer (REST endpoints) and an adapter layer (wrapping `MusicClient` in async context). The frontend has three layers: UI (screens and widgets), state (Riverpod providers), and services (API client, audio service, SQLite DAOs). All business logic lives in Riverpod providers and service classes — screens are pure render-and-watch.

**Major components:**
1. **FastAPI adapter backend** — Accepts requests, wraps `MusicClient` with `run_in_executor`, maps `SongInfo` to `TrackDTO`, proxies audio streams with Range support
2. **Audio stack (just_audio + audio_service + AudioHandler)** — Background foreground service, MediaSession, notification controls, queue management across UI and background isolates
3. **SQLite local store (sqflite + Drift-optional)** — Playlists, tracks, playlist_tracks, recently_played, search_history; singleton database with WAL mode
4. **Riverpod providers** — SearchProvider, PlayerProvider, PlaylistRepository; all async state flows through here, screens read-only
5. **API client (dio)** — Single configured Dio instance with API key interceptor; all HTTP calls go through here
6. **TrackDTO / SongInfo boundary** — Internal `SongInfo` fields (`work_dir`, `save_path`, `download_url`, `download_url_status`) must never cross to the Flutter client; `TrackDTO` is the public contract

### Critical Pitfalls

1. **Background audio killed by Android Doze** — Integrate `audio_service` and declare `FOREGROUND_SERVICE_MEDIA_PLAYBACK` in `AndroidManifest.xml` from day one of the audio phase. Cannot retrofit this after playback is built.

2. **Blocking the FastAPI event loop with synchronous musicdl calls** — Every `MusicClient` call must go through `run_in_executor`. Establish this as the only valid pattern in the first endpoint. A single sync call in `async def` freezes all concurrent requests silently.

3. **Streaming URL expiry mid-playback** — Use the proxy approach: FastAPI fetches from CDN and streams bytes to Flutter. Never pass raw CDN URLs to the Flutter client. This also solves the CORS/cleartext HTTP problem (Pitfall 9) and HLS segment auth problem (Pitfall 7) simultaneously.

4. **Android Scoped Storage breakage on downloads** — Use `path_provider` (never hardcoded paths). Test on a physical Android 13+ device from the start. `WRITE_EXTERNAL_STORAGE` is silently denied on API 33+.

5. **SQLite concurrent write contention** — Single `Database` singleton, WAL mode enabled on open, all writes routed through a repository class. Define the schema with migrations from day one — adding columns post-launch without migrations is painful.

---

## Implications for Roadmap

Based on research, the dependency chain is: backend API must exist before Flutter can be developed; search must work before playback can be tested; playback must exist before downloads make sense; downloads must exist before playlist management is complete. This dictates a 5-phase structure.

### Phase 1: Backend API Foundation

**Rationale:** Flutter development is blocked without API endpoints to call. The proxy-vs-passthrough streaming decision must be made here because it affects every subsequent phase. This is the lowest-risk phase technically but the highest-leverage — getting the `SongInfo → TrackDTO` boundary wrong propagates everywhere.

**Delivers:** Working FastAPI server with `/search`, `/stream`, `/download` routes; `run_in_executor` wrapping pattern established; `TrackDTO` schema locked; API key auth configured; server accessible from Flutter emulator

**Addresses:** Search (backend-ready), streaming URL design, download task initiation

**Avoids:** Event loop blocking (Pitfall 4), URL expiry (Pitfall 2), pickle security (Pitfall 15), rich.Progress log pollution (Pitfall 12), fake_useragent startup failure (Pitfall 13)

**Research flag:** Standard patterns — FastAPI docs are comprehensive; `run_in_executor` is well-documented. No additional research phase needed.

### Phase 2: Flutter Scaffold + Search

**Rationale:** Validates the full API-to-UI loop before investing in the most complex Flutter component (audio). Getting a search result list rendering on device confirms the Riverpod provider pattern, dio client, and navigation shell are working end-to-end.

**Delivers:** Flutter project with Riverpod + go_router configured; `ApiClient` wired to Phase 1 endpoints; working Search screen with result cards showing cover art, format badge, source indicator; bottom navigation shell

**Addresses:** Keyword search, cover art, source indicator, format/quality display

**Avoids:** Null field crashes from sparse sources (Pitfall 6) — define strict `TrackDTO` schema with nullable fields and Dart null-safe fallbacks

**Research flag:** Standard patterns — Riverpod, go_router, dio are well-documented Flutter packages.

### Phase 3: Audio Playback

**Rationale:** The most architecturally complex Flutter component. `just_audio` + `audio_service` span two Android processes. `AudioHandler` must be implemented before any playback features — you cannot add it later. Background playback (the hardest problem) is addressed here, not as a follow-on.

**Delivers:** Background audio playback with Android notification controls and lock screen integration; mini player widget persistent across all screens; full player screen with seek bar, skip, shuffle, repeat; queue management

**Addresses:** Play/pause, seek, skip, shuffle, repeat, background playback, notification controls, headset buttons, audio focus, mini player

**Avoids:** Background audio killed by Android Doze (Pitfall 1), blank MediaSession notifications (Pitfall 10), HLS seek accuracy limitations accepted as known behavior (Pitfall 14)

**Research flag:** Needs deeper research — `audio_service` AudioHandler implementation details and background isolate IPC patterns are moderately complex. Package versions need pub.dev verification before implementation.

### Phase 4: Downloads + Offline Playback

**Rationale:** Depends on Phase 1 backend download route and Phase 3 audio infrastructure (local file:// playback). Scoped Storage constraints must be researched and addressed before any download code is written.

**Delivers:** Download to device with progress indicator; Downloads library screen; offline playback of downloaded files (no backend call); download status indicator per track

**Addresses:** Download to device, offline playback, download status display, Downloads library screen

**Avoids:** Scoped Storage breakage on Android 10+ (Pitfall 3), stale download URL expiry (Pitfall 8 — store source+ID, re-resolve at download time, never cache raw URL)

**Research flag:** Needs targeted verification — Android Scoped Storage / `path_provider` file paths and `MediaStore` integration for music library visibility need confirmation against current Android API level targets.

### Phase 5: Playlists + Library Polish

**Rationale:** All foundational pieces exist. Playlist management is pure SQLite CRUD with Riverpod streams driving reactive UI. This phase also completes the local database schema (search history, recently played), which should be schema-designed early even if built last.

**Delivers:** Create/edit/delete playlists; add/remove songs from playlists; drag-to-reorder; search history persistence; recently played list; offline mode detection; notification controls polish; dark theme finalization

**Addresses:** Playlist CRUD, search history, recently played, library screen, empty states, OEM notification guidance

**Avoids:** SQLite concurrent write contention (Pitfall 5), song identity cross-source ambiguity (Pitfall 11 — composite `(source, identifier)` key in schema)

**Research flag:** Standard patterns — SQLite CRUD with Riverpod streams is well-documented. No additional research phase needed.

### Phase Ordering Rationale

- Backend first because Flutter cannot be developed without callable endpoints; this is a hard dependency.
- Search before audio because it validates the full API-to-UI pipeline cheaply, before the most expensive component (audio) is built.
- Audio before downloads because local file playback (`file://` URI) requires the audio stack to exist.
- Downloads before playlists because undownloaded playlist entries are functionally incomplete; the "add to playlist" UX is more useful once download status is visible.
- SQLite schema should be designed in Phase 1/2 planning even if tables are created in Phase 4/5 — schema decisions affect API contract (song identity model).

### Research Flags

Phases needing deeper research during planning:
- **Phase 3 (Audio Playback):** `audio_service` AudioHandler IPC pattern is non-trivial. Background isolate state synchronization with Riverpod needs concrete example. Package versions (just_audio, audio_service, audio_session) need pub.dev verification — training data confidence is MEDIUM.
- **Phase 4 (Downloads):** Android Scoped Storage / `MediaStore` integration for making downloaded music appear in the system library. `path_provider` path selection on different Android OEM configurations. Needs Android documentation review.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Backend API):** FastAPI, Pydantic, `run_in_executor` patterns are extensively documented with HIGH confidence official sources.
- **Phase 2 (Flutter + Search):** Riverpod, go_router, dio are well-documented. Material 3 component patterns are stable.
- **Phase 5 (Playlists):** SQLite CRUD with reactive Riverpod streams follows established Flutter patterns.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM-HIGH | Backend stack HIGH (FastAPI docs verified). Flutter library versions MEDIUM (pub.dev access denied; training data versions need verification before pubspec.yaml). |
| Features | HIGH | Music player UX patterns are stable and well-established. Spotify/Apple Music/YT Music conventions are extensively documented. Backend capability confirmed by codebase analysis. |
| Architecture | HIGH | Derived from direct codebase analysis + established FastAPI and Flutter patterns. `run_in_executor` pattern is HIGH confidence. Audio stack architecture is MEDIUM (IPC details). |
| Pitfalls | HIGH | Android foreground service, Scoped Storage, and FastAPI async pitfalls are directly documented at platform/framework level. Codebase-specific pitfalls derived from source analysis. |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Flutter package versions:** All `^X.x` versions are from training data. Before writing `pubspec.yaml`, verify current versions of `flutter_riverpod`, `just_audio`, `audio_service`, `audio_session`, `go_router`, `dio`, `sqflite`, `freezed` on pub.dev.

- **Apple Music DRM in cloud deployment:** The existing codebase expects local DRM services on `127.0.0.1:10020` and `127.0.0.1:30020`. Apple Music streaming will not work in a pure cloud FastAPI deployment without a DRM sidecar. Either disable Apple Music or document the sidecar requirement before Phase 1 deployment.

- **HLS streaming mode vs download mode:** The backend's `HLSDownloader` assembles segments to disk. For live streaming, the backend must either (a) proxy segments with auth headers, or (b) serve a partially-downloaded temp file progressively. This architectural decision needs to be made in Phase 1 before the `/stream` endpoint is designed.

- **Concurrent source thread count:** 21 sources with internal `ThreadPoolExecutor` per source may spawn 100+ threads per search request. Server `ulimit` and thread pool sizing need explicit configuration. No default is safe.

- **Song identity for cross-source deduplication:** The database schema must use `(source, identifier)` composite key. There is no canonical cross-source ID. The implications for "offline playlist entry becomes unresolvable when source goes down" need a defined UX response before Phase 5 implementation.

---

## Sources

### Primary (HIGH confidence)

- FastAPI release notes: https://fastapi.tiangolo.com/release-notes/ — version 0.135.2 current, ORJSONResponse deprecated
- FastAPI async docs: https://fastapi.tiangolo.com/async/ — `run_in_executor` pattern
- FastAPI streaming: https://fastapi.tiangolo.com/advanced/custom-response/ — StreamingResponse, FileResponse
- FastAPI bigger applications: https://fastapi.tiangolo.com/tutorial/bigger-applications/ — APIRouter structure
- Flutter release notes: https://docs.flutter.dev/release/release-notes — Flutter 3.41.5 current stable
- Flutter navigation docs: https://docs.flutter.dev/ui/navigation — go_router recommended
- Flutter SQLite docs: https://docs.flutter.dev/packages-and-plugins/using-packages — sqflite official recommendation
- Android foreground services: https://developer.android.com/guide/components/foreground-services — background audio requirements
- Android Scoped Storage: https://developer.android.com/about/versions/11/privacy/storage — download path constraints
- Existing codebase analysis: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/CONCERNS.md`

### Secondary (MEDIUM confidence)

- Riverpod over Provider for production apps — community consensus + official Flutter state management comparison
- just_audio + audio_service combination — Flutter Android dev migration docs reference; packages by same author (ryanheise)
- dio over http package for interceptor-required scenarios — community pattern analysis
- Drift over sqflite for typed queries — established Flutter community pattern
- audio_service AudioHandler IPC architecture — package documentation knowledge

### Tertiary (LOW confidence)

- All Flutter package version numbers (^X.x) — training data only; must verify on pub.dev before implementation
- fake_useragent remote fetch behavior — derived from package source knowledge; verify before containerization

---

*Research completed: 2026-03-26*
*Ready for roadmap: yes*
