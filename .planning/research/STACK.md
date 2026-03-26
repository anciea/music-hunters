# Technology Stack

**Project:** MusicDL Mobile — Flutter Android app + Python FastAPI backend
**Researched:** 2026-03-26
**Overall confidence:** MEDIUM-HIGH (core stack HIGH; audio library versions LOW without pub.dev access)

---

## Recommended Stack

### Backend: Python FastAPI

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Python | 3.11+ | Runtime | Matches existing musicdl codebase. Required for curl_cffi, pywidevine, aigpy. |
| FastAPI | 0.135.x | HTTP API framework | Current stable. Native async support, Pydantic v2 validation, auto OpenAPI docs, SSE support added in 0.135.0. |
| Pydantic | v2 (bundled with FastAPI) | Request/response models | Rust-based serialization. FastAPI 0.100+ requires v2. Define `SongInfo` response schemas matching existing dataclass. |
| Uvicorn | latest | ASGI server | FastAPI's own CLI (`fastapi run`) uses Uvicorn. For cloud deployment with multi-core: `fastapi run --workers 4 main.py`. |

**FastAPI version note (HIGH confidence):** Version 0.135.2 released March 2026. `ORJSONResponse` and `UJSONResponse` are deprecated as of 0.131.0 — do not use them. Pydantic v2's built-in serialization replaces the need for orjson in response handling.

**Streaming note (HIGH confidence):** FastAPI 0.135.0 added native SSE support. For audio proxying, use `StreamingResponse` with an async generator. For serving downloaded files, prefer `FileResponse` which sets `Content-Length`, `ETag`, and `Last-Modified` automatically.

### Backend: Structure and Routing

| Technology | Purpose | Why |
|------------|---------|-----|
| `APIRouter` (FastAPI built-in) | Modular route organization | One router per domain: `/search`, `/stream`, `/download`, `/playlists`. Follows FastAPI's "bigger applications" pattern. |
| `BackgroundTasks` (FastAPI built-in) | Fire-and-forget lightweight tasks | Suitable for logging/notifications. **Not** for download operations. |
| CORS Middleware (FastAPI built-in) | Allow mobile client origin | Required if ever testing from web/emulator with different origin. |

**What NOT to use — task queues:** The existing musicdl library is synchronous (uses `ThreadPoolExecutor` internally). Download operations should be run with `asyncio.run_in_executor()` to avoid blocking the async event loop. Celery/Redis is overkill for a personal single-user backend — it adds operational complexity (separate broker process, worker processes) without benefit at this scale.

**What NOT to use — databases on backend:** The project spec stores playlists locally on device (SQLite). The backend is stateless — no server-side SQLite, PostgreSQL, or Redis needed. The backend is a pure adapter layer over the musicdl library.

### Backend: Security

| Technology | Purpose | Why |
|------------|---------|-----|
| API key via `Header` | Lock down personal backend | FastAPI's `APIKeyHeader` from `fastapi.security`. Single static key in env var. No user accounts needed. Middleware applied globally at `app` level. |

**What NOT to use:** OAuth2 / JWT — significant complexity for a personal single-user backend. HTTP Basic Auth — credentials visible in logs. No auth at all — backend exposed on public cloud server will be scraped.

---

### Flutter Frontend

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter | 3.41.x (stable) | App framework | Current stable as of Feb 2026. Material 3 is default since 3.16. Android-first with iOS expansion path. |
| Dart | 3.x (bundled with Flutter 3.41) | Language | No choice; comes with Flutter. |

**Flutter version note (HIGH confidence):** Flutter 3.41.5 is current stable (Feb 2026). Material 3 is the default design language — do not opt out or target Material 2.

### Flutter: State Management

**Recommendation: Riverpod 2.x**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| flutter_riverpod | ^2.x | App-wide state management | Riverpod is the evolved successor to Provider. No `BuildContext` required for reading state, compile-time safety, native async state (`AsyncValue`), and better testability than Provider. Ideal for async music search results and playback state. |

**Flutter docs recommend Provider** as the beginner-friendly default, but Riverpod is the de-facto standard for production Flutter apps with complex async state. A music player has inherently complex async state: search loading, stream buffering, download progress, playlist mutations. Provider's `ChangeNotifier` becomes unwieldy at this scale.

**What NOT to use:**
- `setState` — fine for isolated local widget state only, not app-wide audio or search state
- `BLoC` — verbose boilerplate for a personal app with no team
- Redux — unnecessary indirection for this scope
- `GetX` — opinionated magic, poor separation of concerns, known maintenance issues

**Confidence:** MEDIUM — Riverpod version not verified against pub.dev (access denied). Based on training data + official Flutter state management guidance + community consensus.

### Flutter: Navigation

**Recommendation: go_router**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| go_router | ^14.x | Navigation and routing | Flutter team's recommended routing package for non-trivial apps. Declarative URL-based routing. Eliminates named routes (explicitly discouraged in Flutter docs). Supports deep links and back navigation. |

**What NOT to use:**
- `Navigator.push()` with `MaterialPageRoute` — fine for 2-3 screens, becomes spaghetti for a music app with Search, NowPlaying, Library, Playlists, Downloads screens
- `Named routes` — explicitly discouraged by Flutter docs
- `auto_route` — code generation overhead not needed for this app size

**Confidence:** HIGH — go_router is directly referenced in official Flutter navigation docs as the recommended approach for apps with complex routing needs.

### Flutter: HTTP Client

**Recommendation: dio**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| dio | ^5.x | HTTP client for API requests | Interceptors for global API key injection, timeout configuration, retry logic, and request cancellation. The `http` package is simpler but lacks interceptors — you'd replicate interceptor logic manually across every service class. |

**Flutter docs recommend the `http` package** as the official simple solution. However, `dio` is the production standard for apps that need:
1. A global auth header interceptor (API key on every request)
2. Request cancellation (user types new search query)
3. Timeout handling with retry

For this app, every single API call needs the auth header and timeout config. `dio` interceptors handle this in one place.

**What NOT to use:**
- Raw `http` package — requires manual header injection on every call
- `dart:io HttpClient` — platform-dependent, explicitly warned against in Flutter docs

**Confidence:** MEDIUM — dio recommended from training data + community patterns. Version not verified against pub.dev (access denied).

### Flutter: Audio Playback

**Recommendation: just_audio + audio_service**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| just_audio | ^0.9.x | Audio engine | Supports HTTP streaming URLs, local files, playlists/queue management, seek, shuffle, repeat, gapless playback. Built on ExoPlayer (Android). Actively maintained. |
| audio_service | ^0.18.x | Background audio + notifications | Integrates just_audio with Android's media notification, lock screen controls, play/pause from notification bar. Required for any music app — without it, audio stops when app is backgrounded. |

**Why these two together:** `just_audio` handles audio decoding and playback; `audio_service` handles the Android foreground service and media session required for background playback. They are designed to work together and share an author (ryanheise).

**What NOT to use:**
- `audioplayers` — simpler but lacks playlist queue management and gapless playback
- `flutter_sound` — oriented toward recording/voice, not music streaming
- Native MediaPlayer via platform channel — unnecessary complexity when just_audio wraps ExoPlayer

**Confidence:** MEDIUM — just_audio and audio_service are well-established in the Flutter ecosystem. Versions not verified against pub.dev (access denied). Based on training data + reference in official Flutter Android dev migration docs.

### Flutter: Local Database

**Recommendation: sqflite**

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| sqflite | ^2.x | Local SQLite database | Store playlists, playlist-song associations, downloaded song metadata, search/play history. Official Flutter recommendation. Widely used. |
| path_provider | ^2.x | File system paths | Get the Android app's documents/cache directory for database file location and downloaded audio files. Required companion to sqflite. |

**Why sqflite over drift:** `drift` (formerly moor) is an ORM with code generation — powerful but adds build tooling complexity. For this app's simple schema (playlists, songs, downloads), raw sqflite SQL is sufficient and avoids the build_runner dependency. Use drift if the schema grows complex.

**What NOT to use:**
- `hive` — fast key-value store, but relational data (playlist contains N songs) is harder to model
- `isar` — high performance but overkill; heavier dependency for personal app
- `ObjectBox` — commercial license considerations for distribution

**Confidence:** HIGH — sqflite is directly mentioned in official Flutter documentation and Android dev migration guide as the SQLite solution.

### Flutter: Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| shared_preferences | ^2.x | Small key-value storage | User settings: selected theme, default quality preference, API base URL. Not for playlist data. |
| permission_handler | ^11.x | Android permissions | Request storage read/write for downloading audio files. |
| cached_network_image | ^3.x | Album art caching | Load and cache cover art URLs returned by API. Prevents re-fetching on scroll. |
| flutter_cache_manager | ^3.x | Generic network cache | Cache audio segments for progressive loading (if not handled by ExoPlayer). Dependency of cached_network_image. |
| freezed | ^2.x | Immutable data classes | Define `SongInfo`, `SearchResult`, `Playlist` as immutable Dart models with `copyWith`. Eliminates manual equality/hashCode. Requires build_runner. |
| json_serializable | ^6.x | JSON deserialization | Auto-generate `fromJson`/`toJson` for API response models. Requires build_runner. Pair with freezed. |
| build_runner | ^2.x | Code generation | Required for freezed + json_serializable. One-time setup cost, large DX benefit. |

**Confidence for supporting libraries:** MEDIUM — versions based on training data. Verify against pub.dev before setting `pubspec.yaml`.

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Backend framework | FastAPI | Flask | Flask lacks async-native support; no auto validation/docs |
| Backend framework | FastAPI | Django REST | Heavy ORM/admin overhead for a stateless adapter layer |
| State management | Riverpod | Provider | Provider lacks compile-time safety; `ChangeNotifier` unwieldy for async state |
| State management | Riverpod | BLoC | Excessive boilerplate for a personal app |
| Navigation | go_router | Named routes | Explicitly discouraged by Flutter docs |
| HTTP client | dio | http package | No interceptors; manual header injection on every call |
| Audio | just_audio | audioplayers | No queue/playlist management in audioplayers |
| Local DB | sqflite | drift | ORM + code generation overhead for a simple schema |
| Local DB | sqflite | hive | Relational data is awkward in key-value stores |
| ASGI server | uvicorn | gunicorn | Gunicorn workers are not async-native; uvicorn is the FastAPI team's recommendation |
| Task queue | none (run_in_executor) | Celery | Single-user personal backend; Celery requires separate broker process |

---

## Key Integration Notes

### musicdl library as backend dependency

The existing `MusicClient` class is **synchronous and thread-based**. FastAPI is async. The integration pattern:

```python
import asyncio
from musicdl.musicdl import MusicClient

@app.get("/search")
async def search(q: str):
    loop = asyncio.get_event_loop()
    results = await loop.run_in_executor(None, music_client.search, q)
    return results
```

Use `run_in_executor` (default ThreadPoolExecutor) to run all musicdl calls. This prevents blocking the uvicorn event loop while musicdl's internal threads do their work.

**Do not** run musicdl calls directly in async endpoints with `await` — musicdl functions are not coroutines and will block the event loop.

### Audio streaming architecture

Two streaming modes depending on source:

1. **Remote URL proxy:** musicdl returns a `download_url` pointing to an external CDN. The FastAPI backend proxies the audio bytes using `StreamingResponse` with range request support (required for seek-to-position in Android's ExoPlayer). The Flutter app calls the `/stream/{song_id}` endpoint, not the CDN directly — this keeps API keys and session cookies server-side.

2. **Local file serving:** For downloaded songs on the Android device, `just_audio` reads from the local file path directly — no backend involvement.

### SongInfo serialization

The existing `SongInfo` dataclass has fields (e.g., `download_url_status`) that are internal state, not appropriate for API responses. Define a separate Pydantic `SongResponse` model with only the fields the Flutter app needs. Use FastAPI's `response_model` parameter to enforce this filtering automatically.

---

## Installation

### Backend

```bash
# Create separate virtualenv for the API layer
python -m venv .venv
source .venv/bin/activate

# Install musicdl as local dependency
pip install -e .

# Install FastAPI and server
pip install "fastapi[standard]"   # Includes uvicorn, pydantic v2, httpx
```

### Flutter

```bash
# Create Flutter app
flutter create musicdl_app --platforms android

# Add dependencies
flutter pub add flutter_riverpod riverpod_annotation
flutter pub add go_router
flutter pub add dio
flutter pub add just_audio audio_service
flutter pub add sqflite path_provider
flutter pub add shared_preferences permission_handler
flutter pub add cached_network_image

# Code generation
flutter pub add --dev build_runner freezed json_serializable riverpod_generator
```

---

## Sources

| Claim | Source | Confidence |
|-------|--------|------------|
| FastAPI 0.135.2 current stable | https://fastapi.tiangolo.com/release-notes/ | HIGH |
| ORJSONResponse deprecated in 0.131.0 | https://fastapi.tiangolo.com/release-notes/ | HIGH |
| StreamingResponse pattern | https://fastapi.tiangolo.com/advanced/custom-response/ | HIGH |
| BackgroundTasks not for heavy ops | https://fastapi.tiangolo.com/tutorial/background-tasks/ | HIGH |
| APIRouter modular structure | https://fastapi.tiangolo.com/tutorial/bigger-applications/ | HIGH |
| Uvicorn --workers recommendation | https://fastapi.tiangolo.com/deployment/server-workers/ | HIGH |
| Flutter 3.41.5 current stable | https://docs.flutter.dev/release/release-notes | HIGH |
| Material 3 default since Flutter 3.16 | https://docs.flutter.dev/ui/widgets/material | HIGH |
| go_router recommended for complex routing | https://docs.flutter.dev/ui/navigation | HIGH |
| http package official recommendation | https://docs.flutter.dev/data-and-backend/networking | HIGH |
| sqflite for SQLite persistence | https://docs.flutter.dev/packages-and-plugins/using-packages | HIGH |
| Provider for beginner state management | https://docs.flutter.dev/data-and-backend/state-mgmt/simple | HIGH |
| compute() for background JSON parsing | https://docs.flutter.dev/cookbook/networking/background-parsing | HIGH |
| just_audio + audio_service stack | Flutter Android dev migration docs reference | MEDIUM |
| Riverpod over Provider for production | Training data + community consensus | MEDIUM |
| dio over http package | Training data + interceptor requirement analysis | MEDIUM |
| Flutter library versions (^X.x) | Training data only — verify on pub.dev | LOW |

---

*Research completed: 2026-03-26*
