# Phase 1: Backend API - Research

**Researched:** 2026-03-26
**Domain:** FastAPI async wrapper around synchronous Python library; HTTP Range streaming; API Key auth; in-memory TTL caching
**Confidence:** HIGH

## Summary

This phase wraps the existing `MusicClient` Python library as a FastAPI REST API. The library is entirely synchronous (uses `ThreadPoolExecutor` internally), so every call into it from an async FastAPI handler must be dispatched via `loop.run_in_executor`. Failure to do this will block the entire event loop and serialize all requests.

The stream endpoint is the most technically demanding part. The backend must proxy audio bytes from upstream CDN URLs (which may be short-lived) to the Flutter client, with correct HTTP Range support so `just_audio` can seek. This requires the server to forward the client's `Range` header upstream, receive a `206 Partial Content` response, and re-emit it as a FastAPI `StreamingResponse` with matching headers.

The search endpoint must aggregate results from all sources without blocking on slow ones. The existing `MusicClient.search()` already uses `ThreadPoolExecutor` internally to parallelize per-source calls; wrapping it in `run_in_executor` is sufficient — do not add another parallelism layer on top. A `cachetools.TTLCache` keyed by keyword with a 5-minute TTL avoids hammering sources on repeated identical queries.

**Primary recommendation:** Create an `api/` package beside `musicdl/`. Instantiate `MusicClient` once in a FastAPI lifespan handler. Use `asyncio.get_event_loop().run_in_executor(executor, ...)` with a dedicated `ThreadPoolExecutor` (not the default one) so worker count can be tuned independently. Use `httpx.AsyncClient` for the proxy streaming requests so the event loop is never blocked by outbound HTTP calls.

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Stream uses proxy mode — backend receives audio from upstream CDN and forwards to client, never exposing raw CDN URLs
- FastAPI async with `run_in_executor` wrapping synchronous MusicClient calls via ThreadPoolExecutor
- Flat TrackDTO response extracted from SongInfo: song_name, singers, album, cover_url, duration_s, duration, source, ext, bitrate, codec, file_size, file_size_bytes
- Static API Key authentication via `X-API-Key` header — sufficient for personal use
- Track identification: composite ID format `{source}:{song_identifier}` — unique, decodable, used for stream/download requests
- Stream endpoint supports HTTP Range requests — required for Flutter just_audio seek functionality
- Unified error response: `{"error": "message", "code": "ERROR_CODE"}` with appropriate HTTP status codes
- Search returns partial results + `warnings` field listing failed/timed-out sources — never blocks on slow sources
- Uvicorn + systemd service deployment on cloud server
- Short-term in-memory search cache with TTL 5 minutes using `cachetools.TTLCache`
- Python logging with file rotation for diagnostics
- CORS allows all origins — API Key provides security for personal use

### Claude's Discretion
- Standard FastAPI patterns apply; open to any file structure that matches standard FastAPI conventions
- No specific requirements on anything not listed above

### Deferred Ideas (OUT OF SCOPE)
- None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| API-01 | FastAPI backend exposes `/search` endpoint that accepts keyword query and returns unified results from all sources | MusicClient.search() maps directly; run_in_executor wraps sync call; TTLCache keyed by keyword |
| API-02 | FastAPI backend exposes `/stream` endpoint that returns playable audio URL for a given track | Composite track_id decoded to (source, identifier); SongInfo retrieved; httpx.AsyncClient proxies bytes with Range forwarding; StreamingResponse emits audio |
| API-03 | FastAPI backend exposes `/download` endpoint that returns audio file for local storage | MusicClient.download() writes file to disk; FileResponse returns it; temp cleanup after send |
</phase_requirements>

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| fastapi | 0.135.2 | Web framework, routing, Pydantic models, OpenAPI | Industry standard for Python async APIs; native Pydantic v2 integration |
| uvicorn | 0.42.0 | ASGI server | Standard FastAPI deployment server; systemd service target |
| httpx | 0.28.1 | Async HTTP client for proxy streaming | Async-native; supports streaming response bodies; replaces blocking `requests` in async context |
| cachetools | 7.0.5 | TTLCache for search results | Lightweight; TTLCache is exactly the primitive needed; thread-safe with a lock |
| python-multipart | 0.0.22 | Required by FastAPI for form data parsing | FastAPI hard dependency for form/file endpoints |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| pydantic | (bundled with fastapi) | TrackDTO schema, request/response validation | Always — FastAPI Pydantic models for all I/O |
| logging (stdlib) | stdlib | File-rotating logs | Use `RotatingFileHandler`; no third-party logging lib needed |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| httpx | aiohttp | Both work; httpx has cleaner API and is the FastAPI-ecosystem standard |
| cachetools.TTLCache | Redis | Redis is overkill for personal single-server use; TTLCache lives in-process |
| uvicorn standalone | gunicorn + uvicorn workers | Multi-worker not needed for personal use; single uvicorn process under systemd is simpler |

**Installation:**
```bash
pip install fastapi==0.135.2 uvicorn==0.42.0 httpx==0.28.1 cachetools==7.0.5 python-multipart==0.0.22
```

**Version verification:** Confirmed against PyPI registry on 2026-03-26.

---

## Architecture Patterns

### Recommended Project Structure
```
api/
├── main.py           # FastAPI app, lifespan, CORS, router includes
├── auth.py           # X-API-Key dependency
├── deps.py           # Shared dependencies (MusicClient instance, executor, cache)
├── models.py         # Pydantic models: TrackDTO, SearchResponse, ErrorResponse
├── routers/
│   ├── search.py     # GET /search
│   ├── stream.py     # GET /stream/{track_id}
│   └── download.py   # GET /download/{track_id}
└── utils.py          # track_id encode/decode helpers, run_in_executor wrapper
requirements-api.txt  # FastAPI stack deps separate from musicdl deps
```

This sits beside `musicdl/` at the repo root — not inside it — to keep the API layer clearly separate from the library.

### Pattern 1: MusicClient Lifespan Initialization
**What:** Create `MusicClient` and `ThreadPoolExecutor` once at startup via FastAPI `lifespan` context manager; store in `app.state`. Teardown on shutdown.
**When to use:** Always — `MusicClient` init is expensive (21 source clients); must not be re-created per request.
**Example:**
```python
# Source: FastAPI official docs - lifespan events
from contextlib import asynccontextmanager
from concurrent.futures import ThreadPoolExecutor
from fastapi import FastAPI
from musicdl.musicdl import MusicClient

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.executor = ThreadPoolExecutor(max_workers=10)
    app.state.music_client = MusicClient(music_sources=[...])
    yield
    app.state.executor.shutdown(wait=True)

app = FastAPI(lifespan=lifespan)
```

### Pattern 2: run_in_executor Wrapper
**What:** Every call to `MusicClient.search()` or `MusicClient.download()` must be dispatched to the thread pool. Never call sync blocking code directly in an async handler.
**When to use:** All MusicClient calls, always.
**Example:**
```python
import asyncio
from functools import partial

async def run_sync(executor, func, *args, **kwargs):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(executor, partial(func, *args, **kwargs))

# In a route handler:
results = await run_sync(request.app.state.executor, client.search, keyword=q)
```

### Pattern 3: TTLCache with Thread Lock
**What:** `cachetools.TTLCache` is not thread-safe for concurrent reads/writes. Protect it with a `threading.Lock`.
**When to use:** All cache read and write operations.
**Example:**
```python
import threading
from cachetools import TTLCache

search_cache: TTLCache = TTLCache(maxsize=256, ttl=300)
cache_lock = threading.Lock()

def get_cached(key):
    with cache_lock:
        return search_cache.get(key)

def set_cached(key, value):
    with cache_lock:
        search_cache[key] = value
```

### Pattern 4: Proxy Stream with Range Request Forwarding
**What:** The `/stream` endpoint receives a client `Range` header, opens an `httpx.AsyncClient` to the upstream URL, forwards the `Range` header, and streams the response body back as a `StreamingResponse`.
**When to use:** `/stream` endpoint only.
**Example:**
```python
import httpx
from fastapi import Request
from fastapi.responses import StreamingResponse

async def stream_audio(track_id: str, request: Request):
    song_info = ...  # look up SongInfo from decoded track_id
    headers = {"Range": request.headers.get("Range", "bytes=0-"), **song_info.default_download_headers}
    async with httpx.AsyncClient() as client:
        upstream = await client.send(
            httpx.Request("GET", song_info.download_url, headers=headers),
            stream=True,
        )
    response_headers = {
        "Content-Type": upstream.headers.get("Content-Type", "audio/mpeg"),
        "Accept-Ranges": "bytes",
        "Content-Range": upstream.headers.get("Content-Range", ""),
        "Content-Length": upstream.headers.get("Content-Length", ""),
    }
    return StreamingResponse(
        upstream.aiter_bytes(chunk_size=65536),
        status_code=upstream.status_code,  # 206 if Range honored
        headers=response_headers,
    )
```

### Pattern 5: Composite Track ID
**What:** Encode `(source, identifier)` as `base64(f"{source}:{identifier}")` to produce a URL-safe opaque token. Decode by splitting on the first `:` after base64 decode.
**When to use:** `/stream/{track_id}` and `/download/{track_id}` path parameters.
**Example:**
```python
import base64

def encode_track_id(source: str, identifier: str) -> str:
    return base64.urlsafe_b64encode(f"{source}:{identifier}".encode()).decode()

def decode_track_id(track_id: str) -> tuple[str, str]:
    raw = base64.urlsafe_b64decode(track_id.encode()).decode()
    source, identifier = raw.split(":", 1)
    return source, identifier
```

Alternatively, keep it as a plain `{source}:{identifier}` string (URL-encoded) — both approaches are valid. Base64 is cleaner for identifiers that contain colons.

### Pattern 6: API Key Dependency
**What:** A FastAPI `Depends` function that reads `X-API-Key` from the request header and raises `HTTP 401` if missing or wrong.
**When to use:** Applied at router level to protect all endpoints.
**Example:**
```python
import os
from fastapi import Header, HTTPException, Security
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != os.environ["MUSICDL_API_KEY"]:
        raise HTTPException(status_code=401, detail={"error": "Invalid API key", "code": "UNAUTHORIZED"})
```

### Anti-Patterns to Avoid
- **Calling `MusicClient.search()` directly in `async def`:** Blocks the event loop; all other requests freeze. Use `run_in_executor` always.
- **Creating a new `MusicClient` per request:** Extremely slow; 21 source clients each run `UserAgent()`, `_initsession()`, etc. Create once in lifespan.
- **Passing `download_url` to the client in the search response:** Violates proxy-mode requirement and exposes raw CDN URLs.
- **Not forwarding `default_download_headers` when proxying:** Many CDN URLs are signed or require specific `Referer`/`Cookie` headers stored in `SongInfo.default_download_headers`. Not forwarding them causes 403.
- **Using `asyncio.to_thread()` without a dedicated executor:** `asyncio.to_thread()` uses the default `ThreadPoolExecutor`, which may be starved. Use a dedicated executor with a known worker count.
- **No lock on TTLCache:** `cachetools.TTLCache` is not documented as thread-safe for concurrent access; the library's own docs recommend external locking.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| TTL expiry cache | Custom dict with timestamps | `cachetools.TTLCache` | Thread-safe with lock; handles maxsize eviction; stdlib-quality |
| HTTP Range proxy | Manual `Content-Range` math | Forward client `Range` header upstream via httpx, re-emit response as-is | Upstream server already computes byte ranges correctly |
| Pydantic schema for SongInfo | Manual JSON serialization dict | Pydantic `BaseModel` (`TrackDTO`) | Automatic validation, OpenAPI docs, null-field stripping |
| File cleanup after download | Manual `os.unlink` + error handling | `tempfile.NamedTemporaryFile(delete=True)` or `BackgroundTask` cleanup | Ensures cleanup even on client disconnect |
| CORS middleware | Manual header injection | `fastapi.middleware.cors.CORSMiddleware` | One-liner; handles preflight OPTIONS automatically |

**Key insight:** The CDN-side Range handling is already correct — the job is purely forwarding headers, not computing ranges.

---

## Common Pitfalls

### Pitfall 1: Event Loop Blocking from Sync MusicClient
**What goes wrong:** `MusicClient.search()` internally creates a `ThreadPoolExecutor` and blocks in `executor.map()`. If called directly in an `async def` handler, it blocks the single event loop thread. All other concurrent requests queue behind it.
**Why it happens:** FastAPI runs on a single-threaded asyncio event loop. Any non-async blocking call freezes it.
**How to avoid:** Always wrap with `await loop.run_in_executor(dedicated_executor, ...)`.
**Warning signs:** All requests slow down when any search is in progress; latency scales linearly with concurrent users.

### Pitfall 2: CDN URL Expiry Between Search and Stream
**What goes wrong:** `SongInfo.download_url` fetched during `/search` may expire by the time the client calls `/stream`. Streaming returns 403/404.
**Why it happens:** Many CDN URLs (QQ Music, Netease, etc.) are signed with short TTLs (60s-5min).
**How to avoid:** Do not cache raw `download_url` in the search response or the search cache. The `/stream` and `/download` handlers must call `MusicClient.download()` (or re-invoke the source client's parse step) at request time to get a fresh URL. The search cache stores only metadata (TrackDTO without download_url); stream/download resolve fresh URLs per request.
**Warning signs:** Streaming works immediately after search but fails if user waits >1 minute.

### Pitfall 3: Missing default_download_headers on Proxy Request
**What goes wrong:** Upstream returns 403 for the proxied stream request.
**Why it happens:** `SongInfo.default_download_headers` contains platform-specific `Referer`, `User-Agent`, and `Cookie` headers that the CDN requires for authentication. Without them, the request looks like a direct scrape and is rejected.
**How to avoid:** Always merge `song_info.default_download_headers` into the httpx request headers when proxying.
**Warning signs:** 403 on stream for some sources but not others (the simpler CDNs don't require headers).

### Pitfall 4: Apple Music DRM Sidecar Not Available
**What goes wrong:** `AppleMusicClient` expects a local DRM sidecar at `127.0.0.1:10020/30020`. On a cloud server without the sidecar, Apple Music requests will hang or crash.
**Why it happens:** DRM decryption requires a local binary that is not part of the musicdl Python package.
**How to avoid:** Exclude `AppleMusicClient` from the `music_sources` list in the API config, or add a health-check on startup that detects the sidecar and logs a warning. Document that Apple Music is disabled in cloud deployment.
**Warning signs:** Startup errors referencing `127.0.0.1:10020` or requests hanging indefinitely for Apple Music source.

### Pitfall 5: Concurrent Cache Writes from run_in_executor Threads
**What goes wrong:** Two search requests for the same keyword arrive simultaneously; both miss the cache and both write back, causing a race condition.
**Why it happens:** `TTLCache.__setitem__` is not atomic under concurrent access.
**How to avoid:** Wrap all cache reads and writes in a `threading.Lock`. Do not use `asyncio.Lock` — the cache is accessed from thread pool workers, not coroutines.
**Warning signs:** Occasional `KeyError` or corrupted cache entries under load.

### Pitfall 6: Download Temp File Leaks
**What goes wrong:** Downloaded audio files accumulate on disk if cleanup is not performed after serving.
**Why it happens:** `MusicClient.download()` writes to `work_dir`. Without explicit cleanup, files persist.
**How to avoid:** Use FastAPI `BackgroundTask` to delete the file after `FileResponse` has been sent. Or write to a `tempfile.mkdtemp()` directory scoped to the request.

---

## Code Examples

### TrackDTO Pydantic Model
```python
from typing import Optional
from pydantic import BaseModel

class TrackDTO(BaseModel):
    track_id: str               # composite: base64("{source}:{identifier}")
    song_name: Optional[str]
    singers: Optional[str]
    album: Optional[str]
    cover_url: Optional[str]
    duration_s: Optional[int]
    duration: Optional[str]
    source: Optional[str]
    ext: Optional[str]
    bitrate: Optional[int]
    codec: Optional[str]
    file_size: Optional[str]
    file_size_bytes: Optional[int]

class SearchResponse(BaseModel):
    tracks: list[TrackDTO]
    warnings: list[str]         # sources that failed or timed out

class ErrorResponse(BaseModel):
    error: str
    code: str
```

### Search Handler Skeleton
```python
from fastapi import APIRouter, Depends, Query, Request
from cachetools import TTLCache
import threading, asyncio
from functools import partial

router = APIRouter()
search_cache: TTLCache = TTLCache(maxsize=256, ttl=300)
cache_lock = threading.Lock()

@router.get("/search", response_model=SearchResponse)
async def search(q: str = Query(..., min_length=1), request: Request = None, _=Depends(verify_api_key)):
    with cache_lock:
        cached = search_cache.get(q)
    if cached:
        return cached
    loop = asyncio.get_event_loop()
    raw_results: dict = await loop.run_in_executor(
        request.app.state.executor,
        partial(request.app.state.music_client.search, q)
    )
    tracks, warnings = [], []
    for source, song_infos in raw_results.items():
        if not song_infos:
            warnings.append(source)
            continue
        for si in song_infos:
            tracks.append(TrackDTO(
                track_id=encode_track_id(source, si.identifier),
                song_name=si.song_name, singers=si.singers, album=si.album,
                cover_url=si.cover_url, duration_s=si.duration_s, duration=si.duration,
                source=si.source, ext=si.ext, bitrate=si.bitrate, codec=si.codec,
                file_size=si.file_size, file_size_bytes=si.file_size_bytes,
            ))
    response = SearchResponse(tracks=tracks, warnings=warnings)
    with cache_lock:
        search_cache[q] = response
    return response
```

### systemd Service Unit
```ini
[Unit]
Description=MusicDL API
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/musicdl
Environment=MUSICDL_API_KEY=changeme
ExecStart=/opt/musicdl/venv/bin/uvicorn api.main:app --host 0.0.0.0 --port 8000
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Python 3 | Runtime | Yes | 3.13.1 | — |
| pip | Package install | Yes | (available) | — |
| fastapi | API framework | No (not installed) | — | Install via pip |
| uvicorn | ASGI server | No (not installed) | — | Install via pip |
| httpx | Async proxy client | No (not installed) | — | Install via pip |
| cachetools | TTL cache | No (not installed) | — | Install via pip |
| Apple Music DRM sidecar | AppleMusicClient | Unknown | — | Exclude AppleMusicClient from sources list |

**Missing dependencies with no fallback:**
- fastapi, uvicorn, httpx, cachetools — all installable; Wave 0 task must run `pip install`.

**Missing dependencies with fallback:**
- Apple Music DRM sidecar — disable `AppleMusicClient` in cloud config.

---

## Project Constraints (from CLAUDE.md)

These directives from CLAUDE.md must be honored by the planner:

1. **Tech stack is locked:** Flutter frontend + Python FastAPI backend. No other frameworks.
2. **Do not modify existing musicdl library:** API layer only wraps `MusicClient`; zero changes to `musicdl/` package internals.
3. **GSD workflow enforcement:** All file edits must go through a GSD command (`/gsd:execute-phase`). No direct repo edits outside GSD workflow.
4. **Naming conventions:** snake_case for all Python files and functions; PascalCase for classes. New files follow existing patterns.
5. **No test framework currently configured:** `config.json` has `nyquist_validation: false` — no test scaffolding required.
6. **Python 3.11+ required** (documented in `.readthedocs.yaml`; machine has 3.13.1 which satisfies this).
7. **Logging via `LoggerHandle` pattern:** New code should use Python's `logging` module consistent with existing patterns, writing to rotating file.

---

## Open Questions

1. **Re-fetching download_url at stream time**
   - What we know: `MusicClient.download()` writes a file to disk rather than returning a fresh `download_url`. Getting a fresh URL requires calling the source client's internal parse step directly.
   - What's unclear: The cleanest way to get a fresh, playable URL from a `BaseMusicClient` without triggering the full download pipeline. Some sources may require re-running `_search()` to get a fresh URL.
   - Recommendation: The stream handler should call `MusicClient.download()` into a temp directory and stream the resulting file, OR inspect each source client's download pipeline to find a "parse only" step. The planner should decide which approach to use — file-based streaming (simpler, works universally) vs. URL re-fetch (lower latency, source-specific).

2. **Search cache invalidation for partial results**
   - What we know: `MusicClient.search()` returns `{}` (empty list) for failed sources.
   - What's unclear: Should a result with all warnings (all sources failed) be cached? Caching a total failure for 5 minutes would block retries.
   - Recommendation: Only cache results where at least one source returned data. If `warnings` equals all sources, do not cache.

3. **Number of ThreadPoolExecutor workers for the dedicated executor**
   - What we know: `MusicClient.search()` already spawns up to 10 threads internally. The outer executor only needs to hold one thread per concurrent API search request.
   - Recommendation: Start with `max_workers=4` for a personal-use server; make it configurable via environment variable.

---

## Sources

### Primary (HIGH confidence)
- PyPI registry (2026-03-26) — fastapi 0.135.2, uvicorn 0.42.0, httpx 0.28.1, cachetools 7.0.5, python-multipart 0.0.22 versions verified
- `musicdl/musicdl.py` — MusicClient.search() and download() interface confirmed by source read
- `musicdl/modules/utils/data.py` — SongInfo fields confirmed by source read
- `musicdl/modules/sources/__init__.py` — 37 registered source clients confirmed

### Secondary (MEDIUM confidence)
- FastAPI official docs pattern — lifespan events, StreamingResponse, Depends auth, CORSMiddleware
- httpx streaming docs — `client.send(..., stream=True)` + `aiter_bytes()` pattern

### Tertiary (LOW confidence)
- CDN URL TTL behavior — inferred from common CDN patterns; actual TTLs vary per source and are not documented in the codebase

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all versions verified against PyPI on 2026-03-26
- Architecture: HIGH — patterns derived directly from FastAPI official docs and existing codebase inspection
- Pitfalls: HIGH for event-loop blocking (well-known FastAPI pattern); MEDIUM for CDN TTL behavior (inferred, not measured)

**Research date:** 2026-03-26
**Valid until:** 2026-04-25 (30 days; FastAPI releases frequently but no breaking changes expected in this window)
