# Architecture Patterns

**Domain:** Flutter + FastAPI Music Streaming App
**Researched:** 2026-03-26
**Confidence:** HIGH (derived from existing codebase analysis + established Flutter/FastAPI patterns)

---

## System Overview

This is a **client-server mobile app** where the Python `musicdl` library becomes the backend brain and Flutter becomes the mobile UI layer. The existing Python codebase is not rewritten — it is wrapped.

```
┌─────────────────────────────────────────────────────────────┐
│                   Android Device                            │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Flutter App                             │  │
│  │                                                      │  │
│  │  UI Layer          State Layer        Service Layer  │  │
│  │  ┌──────────┐     ┌────────────┐     ┌───────────┐  │  │
│  │  │ Screens  │────▶│  Riverpod  │────▶│  API      │  │  │
│  │  │ Widgets  │     │  Providers │     │  Client   │  │  │
│  │  └──────────┘     └────────────┘     └─────┬─────┘  │  │
│  │                                            │         │  │
│  │  ┌──────────┐     ┌────────────┐     ┌─────▼─────┐  │  │
│  │  │  Player  │────▶│  Audio     │     │  SQLite   │  │  │
│  │  │  Widget  │     │  Service   │     │  (local)  │  │  │
│  │  └──────────┘     └────────────┘     └───────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS (REST + streaming)
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Cloud Server                               │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              FastAPI Application                     │  │
│  │                                                      │  │
│  │  API Routes Layer                                    │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  /search  /stream  /download  /playlist      │   │  │
│  │  └──────────────────┬───────────────────────────┘   │  │
│  │                     │                               │  │
│  │  Adapter Layer (existing musicdl modules)            │  │
│  │  ┌──────────────────▼───────────────────────────┐   │  │
│  │  │  MusicClient  ──▶  21 Source Adapters         │   │  │
│  │  │  (musicdl.py)       (BaseMusicClient)         │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  Optional: Redis cache, file temp storage                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Boundaries

### Backend Components

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **FastAPI Router** | Accepts HTTP requests, validates inputs, returns responses | API Client (Flutter), Adapter Layer |
| **Adapter Layer** | Wraps `MusicClient` for async/FastAPI context, maps `SongInfo` to JSON | FastAPI Router, musicdl source adapters |
| **MusicClient** | Existing orchestrator — coordinates multi-source search/download | 21 source client implementations |
| **Source Clients** | Platform-specific HTTP/auth/parsing logic per music service | External music platform APIs |
| **Stream Proxy** | Fetches remote audio URL, re-streams it with Range request support | Flutter Audio Service, external CDN/streaming URLs |
| **Temp File Store** | Manages HLS segment assembly, DRM decrypt scratch space | Source clients (HLS, DRM paths) |
| **Config/Secrets** | Provides per-source cookies, API keys, Widevine WVD to clients | Source clients |

### Frontend Components

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Search Screen** | Search input, results display, source filter | SearchProvider, TrackListWidget |
| **Player Screen** | Now-playing view, controls, seek bar, queue | AudioService, PlayerProvider |
| **Library Screen** | Local playlists, downloaded songs, recently played | PlaylistRepository, LocalDB |
| **Download Manager** | In-progress downloads, completion notifications | API Client, LocalDB, AudioService |
| **API Client** | All HTTP calls to FastAPI, models/DTOs | All providers needing server data |
| **Audio Service** | Background playback, system notification, queue management | `just_audio`, `audio_service` plugins |
| **PlayerProvider** | Current track state, play/pause, seek, queue state | Audio Service, UI layer |
| **SearchProvider** | Search query state, results, loading/error states | API Client |
| **PlaylistRepository** | CRUD for local playlists in SQLite | SQLite (via `drift` or `sqflite`) |
| **LocalDB** | SQLite schema and queries for songs, playlists, history | PlaylistRepository, DownloadManager |

---

## Data Flow

### Search Flow

```
User types query
      │
SearchScreen ──▶ SearchProvider.search(query, sources)
                       │
                 API Client: GET /search?q=...&sources=...
                       │
                 [HTTPS to cloud server]
                       │
                 FastAPI /search route
                       │
                 Adapter Layer: run_in_executor(MusicClient.search)
                       │  (ThreadPoolExecutor — existing sync code)
                       │
                 MusicClient.search() ──▶ [Thread per source]
                 netease, qq, youtube...    └── BaseMusicClient.search()
                                               └── SongInfo[]
                       │
                 Aggregate, deduplicate, serialize to JSON
                       │
                 Response: SearchResultDTO[]
                       │
                 SearchProvider updates state
                       │
                 TrackListWidget rebuilds
```

### Stream Playback Flow (Online)

```
User taps song
      │
PlayerProvider.playSong(track)
      │
AudioService.play(streamUrl)
      │  streamUrl = https://server/stream/{source}/{song_id}
      │
just_audio: issues HTTP GET with Range headers
      │
[HTTPS to cloud server]
      │
FastAPI /stream/{source}/{song_id}
      │
Adapter Layer: client.get_stream_url(song_id)
      │  (calls platform API to get CDN URL, may proxy if CORS/auth)
      │
      ├─► Direct redirect: 307 to CDN URL (no bandwidth cost)
      │   (when CDN URL is publicly accessible)
      │
      └─► Server-side proxy: StreamingResponse with Range support
          (when CDN URL requires server-side auth headers)
                │
           chunked bytes ──▶ just_audio buffer ──▶ audio output
```

### Download Flow

```
User taps "Download"
      │
DownloadManager.enqueue(track)
      │
API Client: POST /download  { source, song_id }
      │  Returns: { task_id }
      │
[Backend: downloads to temp, writes tags, finalizes]
      │
API Client: GET /download/{task_id}/status  (polling or SSE)
      │
On complete: GET /download/{task_id}/file
      │
File saved to Android external storage
      │
LocalDB.insertDownloadedSong(track, localPath)
      │
DownloadManager notifies completion
      │
PlaylistRepository can now reference local file
```

### Local Playback Flow (Offline)

```
User taps downloaded song
      │
PlayerProvider.playLocalFile(localPath)
      │
AudioService.playFromFile(localPath)
      │
just_audio: reads file:// URI directly
      │  (no network call — fully offline)
      │
Audio output
```

---

## How musicdl Gets Wrapped by FastAPI

### The Core Wrapping Problem

`MusicClient` and all source clients are **synchronous** (use `requests`, `ThreadPoolExecutor`). FastAPI is async. Calling blocking sync code directly in an `async def` route blocks the event loop and breaks everything.

**Solution: `asyncio.get_event_loop().run_in_executor()`**

```python
# Pattern for every blocking musicdl call in FastAPI routes
import asyncio
from concurrent.futures import ThreadPoolExecutor

executor = ThreadPoolExecutor(max_workers=10)

@app.get("/search")
async def search(q: str, sources: list[str] = Query(default=["netease"])):
    loop = asyncio.get_event_loop()
    results: list[SongInfo] = await loop.run_in_executor(
        executor,
        lambda: music_client.search(q)
    )
    return [song_info_to_dto(si) for si in results]
```

### FastAPI ↔ musicdl Mapping

| FastAPI Route | musicdl Call | Notes |
|--------------|-------------|-------|
| `GET /search` | `MusicClient.search(keyword)` | Filter by source param |
| `GET /stream/{id}` | `client.get_download_url(song_info)` | May proxy or redirect |
| `POST /download` | `MusicClient.download([song_info])` | Returns task_id |
| `GET /download/{task_id}/status` | Poll background task state | Redis or in-memory dict |
| `GET /playlist` | `MusicClient.parseplaylist(url)` | Returns SongInfo[] |

### SongInfo → API DTO Mapping

The `SongInfo` dataclass is the internal transport model. It must be serialized to a clean JSON DTO for the API:

```python
# Conceptual DTO — hides internal state fields from client
class TrackDTO(BaseModel):
    id: str                    # Derived: f"{source}:{song_id}"
    source: str                # Which platform
    title: str                 # song_name
    artists: list[str]         # singers (split from string)
    album: str
    duration_seconds: int      # duration_s
    cover_url: str | None
    has_lyrics: bool           # lyric != ""
    quality: str               # ext (mp3/flac/m4a)
    stream_url: str            # /stream/{source}/{id} (server route)
```

Internal fields (`download_url`, `work_dir`, `save_path`, `download_url_status`) must NOT be exposed to the Flutter client — these are backend implementation details.

### Stateless vs Stateful Design

The existing `MusicClient` holds per-source session state (cookies, auth headers). In a FastAPI deployment:

- **Single `MusicClient` instance** at application startup, shared across requests. Initialized once with all source configs loaded from environment.
- **Source client state** (sessions, cookies) lives in the shared instance — this is intentional (session reuse reduces auth overhead).
- **Thread safety**: The existing `Lock` objects in source clients protect shared state. `run_in_executor` delegates to threads, not coroutines, so existing locking applies.
- **Per-request state** (search results, download progress) must NOT live on the `MusicClient` instance — use task IDs with an in-memory dict or Redis.

---

## Flutter App Layer Architecture

### State Management: Riverpod

Use **Riverpod** (not Bloc, not Provider). Rationale:
- Compile-safe — providers are typed, no `context.read<T>()` string-keyed lookups
- Async providers built-in — `FutureProvider`, `AsyncNotifier` map cleanly to API calls
- No `BuildContext` dependency in business logic — testable
- `AsyncValue` handles loading/error/data states uniformly

### Layer Structure

```
lib/
├── core/
│   ├── api/               # HTTP client, DTOs, endpoints
│   │   ├── api_client.dart
│   │   ├── models/        # TrackDTO, SearchResultDTO, etc.
│   │   └── endpoints.dart
│   ├── db/                # SQLite schema and DAOs
│   │   ├── database.dart
│   │   ├── playlist_dao.dart
│   │   └── track_dao.dart
│   └── audio/             # Audio service + queue management
│       ├── audio_service.dart
│       └── queue_manager.dart
│
├── features/
│   ├── search/
│   │   ├── search_screen.dart
│   │   ├── search_provider.dart   # Riverpod AsyncNotifier
│   │   └── track_list_widget.dart
│   │
│   ├── player/
│   │   ├── player_screen.dart
│   │   ├── mini_player_widget.dart
│   │   └── player_provider.dart   # Now-playing state
│   │
│   ├── library/
│   │   ├── library_screen.dart
│   │   ├── playlist_provider.dart
│   │   └── download_manager.dart
│   │
│   └── settings/
│       └── settings_screen.dart
│
└── main.dart
```

### Audio Playback Stack

The audio system is the most complex part of the Flutter app. It spans two processes on Android (UI process and background isolate).

**Recommended packages:**
- `just_audio` — Audio player with HLS support, HTTP Range requests, gapless playback
- `audio_service` — Background playback + Android notification controls + lock screen
- `audio_session` — Handle audio focus, interruptions (calls, other apps)

**Architecture:**

```
┌──────────────────────────────────────────────────────────┐
│  UI Process (Flutter app)                                │
│                                                          │
│  PlayerProvider ──── AudioHandler (bridge) ─────────────┤
│  (Riverpod)          (audio_service)        │            │
│                                             │ IPC        │
├─────────────────────────────────────────────┤            │
│  Background Isolate (Android Service)       │            │
│                                             │            │
│  AudioHandler ──── just_audio ──── MediaItem queue      │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

`AudioHandler` is the bridge between Riverpod state and `just_audio`. It:
1. Manages the `just_audio` player instance
2. Handles `MediaItem` metadata for notification display
3. Responds to notification control actions (system sends play/pause/next to handler)
4. Reports playback state changes back to UI via streams

### Local Storage: SQLite via Drift

Use **Drift** (formerly Moor) over raw `sqflite`. Rationale:
- Type-safe queries — compile-time SQL validation
- Streams — reactive queries automatically update UI when DB changes
- Migration system — handles schema evolution
- No raw SQL strings scattered in business logic

**Schema:**

```
playlists (id, name, created_at, updated_at)
playlist_tracks (playlist_id, track_id, position)
tracks (id, source, title, artists_json, album, duration_s, cover_url,
        local_path, downloaded_at, quality)
recently_played (track_id, played_at)
search_history (query, searched_at)
```

---

## Suggested Build Order

The following order respects hard dependencies between components:

### Phase 1: Backend Foundation

**Why first:** Flutter cannot be built without API endpoints to call. The FastAPI wrapper is the prerequisite for all Flutter work.

1. FastAPI project setup with `uvicorn`, `pydantic`, CORS configured
2. `MusicClient` initialization at startup (load config from env)
3. `run_in_executor` wrapper pattern established
4. `/search` route — single source first, then multi-source
5. `TrackDTO` / `SearchResultDTO` schemas locked in
6. `/stream/{source}/{id}` route — redirect vs proxy decision made
7. API documentation verified via `/docs` (FastAPI auto-generates)

### Phase 2: Flutter Scaffold + Search

**Why second:** Validates the full API-to-UI loop before investing in player complexity.

1. Flutter project setup, Riverpod configured
2. `ApiClient` built against Phase 1 endpoints
3. Search screen + `SearchProvider` — full end-to-end search working
4. `TrackListWidget` showing results
5. Navigation shell (bottom nav bar, routing)

### Phase 3: Audio Playback

**Why third:** Most complex Flutter component. Requires search results to exist (Phase 2) to have something to play.

1. `just_audio` + `audio_service` integrated
2. `AudioHandler` implementing background service
3. `PlayerProvider` with play/pause/seek state
4. Mini player widget (persistent at bottom of app)
5. Full player screen
6. Stream URL wired to player (online playback confirmed working)

### Phase 4: Downloads + Local Playback

**Why fourth:** Depends on audio playback infrastructure from Phase 3. Download requires API route from Phase 1.

1. Backend: `/download` POST route + task status polling
2. Flutter: `DownloadManager` service
3. SQLite (Drift) setup: schema, DAOs
4. Local file playback via `just_audio` file:// URI
5. Library screen showing downloaded songs

### Phase 5: Playlists + Polish

**Why last:** All foundational pieces exist. Playlist management is pure CRUD on local SQLite.

1. `PlaylistRepository` CRUD with Drift streams
2. Playlist screens (list, detail, add-to-playlist)
3. Search history, recently played persistence
4. Notification controls polish
5. Offline mode detection (show cached content when offline)

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Calling musicdl Sync Code Directly in async Def

**What:** `result = music_client.search(q)` inside `async def` route handler.
**Why bad:** Blocks FastAPI's event loop. All concurrent requests queue behind it. Effectively makes the server single-threaded.
**Instead:** Always wrap with `run_in_executor`. Establish this as the only valid pattern in the codebase — no exceptions.

### Anti-Pattern 2: Exposing SongInfo Internals to Flutter

**What:** Serializing `SongInfo` dataclass fields directly to API response (including `work_dir`, `save_path`, `download_url_status`).
**Why bad:** Leaks backend state machine details. `download_url` exposes direct CDN URLs that may require server-side auth headers — the Flutter client cannot use them directly (would fail with 403).
**Instead:** Always map through `TrackDTO`. The stream URL exposed to Flutter must always be the server's own `/stream/` route, never a raw CDN URL.

### Anti-Pattern 3: Business Logic in Flutter Screens

**What:** API calls, SQLite queries, or audio control inside `StatefulWidget` or `build()` methods.
**Why bad:** Untestable, causes rebuild storms, mixes concerns. Common pattern in quick Flutter tutorials.
**Instead:** All logic in Riverpod providers and services. Screens are pure "watch state and render" — no async calls, no database access.

### Anti-Pattern 4: One MusicClient Instance Per Request

**What:** Instantiating `MusicClient()` inside each request handler.
**Why bad:** Each instantiation initializes all 21+ source clients with fresh sessions — expensive. Sessions cannot be reused. Breaks any per-source authentication state.
**Instead:** Single `MusicClient` at application startup, injected via FastAPI dependency injection (`Depends(get_music_client)`).

### Anti-Pattern 5: Ignoring HLS vs Direct Stream Distinction

**What:** Treating all stream URLs the same — just passing raw URL to `just_audio`.
**Why bad:** HLS streams (`.m3u8`) require playlist parsing and segment fetching — `just_audio` handles HLS natively. DASH manifests require a different approach. Direct CDN URLs for FLAC may require server-side auth headers that Flutter cannot add.
**Instead:** Backend must classify each stream type and either: (a) redirect to publicly accessible URLs, (b) proxy with required auth headers, or (c) return the m3u8 URL for direct HLS consumption.

---

## Scalability Considerations

| Concern | At personal use (1 user) | At 10 concurrent users | Notes |
|---------|--------------------------|----------------------|-------|
| Search latency | Acceptable (5-10s for 21 sources) | Thread pool exhaustion possible | Add per-request source limits; cache recent searches |
| Stream proxying | Fine | Bandwidth bottleneck if proxying large files | Use redirects over proxying where possible |
| MusicClient sessions | Single instance fine | Session contention on auth refresh | Per-source locking already exists in codebase |
| Download tasks | In-memory task dict fine | Memory pressure | Use background task queue (Celery or asyncio.Queue) |
| SQLite on Android | Fine at any scale for personal use | N/A (local device DB) | WAL mode for concurrent reads |

For v1 (personal use), the architecture above handles all load. Horizontal scaling is not required.

---

## Key Integration Constraints Derived from Existing Code

These constraints from the codebase analysis directly affect architecture decisions:

1. **Apple Music DRM requires local wrapper service** — `appleutils.py` expects `http://127.0.0.1:10020/` and `http://127.0.0.1:30020/` for DRM decryption. This means the FastAPI server cannot run Apple Music DRM in a pure cloud environment without either: (a) a separate DRM sidecar service co-deployed with FastAPI, or (b) disabling Apple Music for the mobile app and using a non-DRM fallback.

2. **Some source auth requires cookies the server must hold** — Deezer `arl`, TIDAL session tokens, Apple `media-user-token` must be configured server-side. They must never flow through the Flutter client. All credentials live in the FastAPI server's environment configuration only.

3. **HLS and DASH segments are assembled server-side** — The existing `HLSDownloader` and DASH pipeline work with local disk. For streaming (not download), the FastAPI `/stream/` route must either: (a) proxy live HLS by fetching segments on-demand, or (b) trigger a background assembly and return a file URL when ready. Option (a) is lower latency; option (b) reuses existing download logic.

4. **Concurrent search creates many outbound connections** — `ThreadPoolExecutor` with 5 threads per source, 21 sources = up to 105 concurrent threads for a single search request. The server needs enough file descriptors and connection pool budget for this. Configure `ulimit` appropriately on the cloud server.

5. **Third-party proxy APIs are fragile** — Several sources (Netease, QQ, Kuwo) rely on external proxy endpoints that can disappear. The FastAPI error handling must surface source-level failures gracefully (some sources fail, others succeed) — never return a 500 for the whole search when one source fails.

---

## Sources

- Existing codebase analysis: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/CONCERNS.md`
- Architecture patterns: Training knowledge (Flutter + FastAPI) — MEDIUM confidence on specific package recommendations
- `just_audio` + `audio_service` combination: Established Flutter audio stack, widely used — MEDIUM confidence (training knowledge, verify versions before implementation)
- Riverpod for state management: Established recommendation over Bloc for new projects in 2024-2025 — MEDIUM confidence
- Drift over sqflite: Established pattern for typed SQLite in Flutter — MEDIUM confidence
- `run_in_executor` for sync-in-async wrapping: FastAPI documented pattern — HIGH confidence
