# Phase 1: Backend API - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Wrap the existing Python musicdl library as a FastAPI REST API. Three endpoints: `/search` (keyword search across all sources), `/stream` (proxied audio byte stream), `/download` (audio file download). The API is the only interface between the Flutter app and the music library — no direct Python library calls from the client.

</domain>

<decisions>
## Implementation Decisions

### API Architecture
- Stream uses proxy mode — backend receives audio from upstream CDN and forwards to client, never exposing raw CDN URLs
- FastAPI async with `run_in_executor` wrapping synchronous MusicClient calls via ThreadPoolExecutor
- Flat TrackDTO response extracted from SongInfo: song_name, singers, album, cover_url, duration_s, duration, source, ext, bitrate, codec, file_size, file_size_bytes
- Static API Key authentication via `X-API-Key` header — sufficient for personal use

### Endpoint Design
- Track identification: composite ID format `{source}:{song_identifier}` — unique, decodable, used for stream/download requests
- Stream endpoint supports HTTP Range requests — required for Flutter just_audio seek functionality
- Unified error response: `{"error": "message", "code": "ERROR_CODE"}` with appropriate HTTP status codes
- Search returns partial results + `warnings` field listing failed/timed-out sources — never blocks on slow sources

### Deployment & Operations
- Uvicorn + systemd service deployment on cloud server
- Short-term in-memory search cache with TTL 5 minutes using `cachetools.TTLCache`
- Python logging with file rotation for diagnostics
- CORS allows all origins — API Key provides security for personal use

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MusicClient` class in `musicdl/musicdl.py` — orchestrates search across all registered sources with thread pool
- `SongInfo` dataclass in `musicdl/modules/utils/data.py` — complete song metadata model with download_url, cover_url, lyrics, etc.
- `MusicClientBuilder` registry in `musicdl/modules/sources/__init__.py` — dynamic client discovery and instantiation
- `BaseMusicClient` base class with `search()` and `download()` interface
- 21 source implementations already registered and working

### Established Patterns
- Thread-based concurrent search across sources (MusicClient.search uses ThreadPoolExecutor)
- SongInfo as the universal data transfer object — all sources produce SongInfo objects
- Decorator-based header/cookie injection (`@usesearchheaderscookies`, `@usedownloadheaderscookies`)
- Source-specific work directories for output organization

### Integration Points
- FastAPI app imports and wraps `MusicClient` — creates instance at startup with configured sources
- TrackDTO is a Pydantic model derived from SongInfo fields
- Stream endpoint needs access to `download_url` and `default_download_headers` from SongInfo
- Search results cached in-memory keyed by keyword for TTL period

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard FastAPI patterns. Key constraint: must not rewrite any existing music client logic, only wrap it.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
