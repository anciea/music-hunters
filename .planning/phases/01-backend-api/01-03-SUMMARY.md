---
phase: 01-backend-api
plan: 03
subsystem: api
tags: [fastapi, httpx, streaming, range-requests, systemd, uvicorn, python]

# Dependency graph
requires:
  - phase: 01-backend-api plan 01
    provides: api scaffold, auth, deps, utils (decode_track_id, run_sync)
  - phase: 01-backend-api plan 02
    provides: search router pattern, SongInfo->TrackDTO mapping
provides:
  - "GET /stream/{track_id} — httpx proxy stream with HTTP Range forwarding and CDN auth header merging"
  - "GET /download/{track_id} — FileResponse audio download with BackgroundTask temp cleanup"
  - "musicdl-api.service — systemd unit file for Linux cloud deployment"
affects: [02-flutter-app, playback, deployment]

# Tech tracking
tech-stack:
  added: [httpx (async streaming client for proxy mode)]
  patterns: [httpx.AsyncClient send+stream=True proxy, BackgroundTask temp cleanup, file fallback streaming]

key-files:
  created:
    - api/routers/stream.py
    - api/routers/download.py
    - musicdl-api.service
  modified: []

key-decisions:
  - "Proxy-first streaming: try httpx CDN proxy with Range forwarding; fall back to file-based streaming on httpx failure or missing URL — handles both direct-URL and opaque-stream sources uniformly"
  - "Reuse _get_fresh_song_info and _download_to_temp from stream.py in download.py — single import avoids duplication, both need identical fresh-URL logic"
  - "download_url never appears in download.py (not even in comments) — strict enforcement of CDN URL opacity contract"

patterns-established:
  - "Pattern: httpx.AsyncClient send+stream=True with aiter_bytes — all proxied streams use this pattern"
  - "Pattern: stream_and_close() async generator — aclose() called in finally block ensures connection cleanup on client disconnect"
  - "Pattern: BackgroundTask(shutil.rmtree, temp_dir, True) — standard temp dir cleanup after FileResponse"
  - "Pattern: _get_fresh_song_info() called at stream/download time, never cached — CDN URLs have short TTLs"

requirements-completed: [API-02, API-03]

# Metrics
duration: 3min
completed: 2026-03-27
---

# Phase 01 Plan 03: Stream, Download, and Deployment Summary

**httpx-proxied audio streaming with HTTP Range forwarding, FileResponse download with BackgroundTask cleanup, and systemd service unit for cloud deployment**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-03-27T02:17:10Z
- **Completed:** 2026-03-27T02:20:12Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Stream endpoint proxies audio bytes via httpx with Range header forwarding — just_audio can seek
- CDN auth headers (Referer/Cookie/UA from `default_download_headers`) always merged into upstream requests
- File-based streaming fallback for sources that lack a direct HTTP CDN URL
- Download endpoint writes to temp dir, serves as FileResponse attachment, cleans up via BackgroundTask
- Systemd service unit ready for `systemctl enable musicdl-api` on cloud server

## Task Commits

Each task was committed atomically:

1. **Task 1: GET /stream/{track_id}** - `e441893` (feat)
2. **Task 2: GET /download/{track_id} + systemd service** - `8d7bd41` (feat)

**Plan metadata:** see final docs commit

## Files Created/Modified
- `api/routers/stream.py` — Full stream implementation: httpx proxy mode with Range forwarding, file fallback, CDN header merging
- `api/routers/download.py` — Download implementation: temp dir + FileResponse + BackgroundTask cleanup
- `musicdl-api.service` — systemd unit: uvicorn as Type=simple, MUSICDL_API_KEY env var, restart on failure

## Decisions Made
- Proxy-first pattern: httpx CDN proxy attempted first; file fallback handles opaque-stream or DRM sources. This is the most robust approach — works for all 15 enabled source types without per-source branching.
- `_get_fresh_song_info` and `_download_to_temp` are imported from `stream.py` into `download.py`. Both endpoints need identical fresh-URL logic; centralizing in stream.py avoids drift.
- Comment in `download.py` referencing `download_url` was changed to avoid literal string match — keeps the CDN URL opacity contract unambiguous even in documentation.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Removed `download_url` string from download.py comment**
- **Found during:** Task 2 verification
- **Issue:** Plan acceptance criteria states `grep "download_url" api/routers/download.py` returns NO match. A comment referencing `download_url` would fail this check.
- **Fix:** Reworded comment from "never use cached download_url" to "always re-fetch at request time"
- **Files modified:** api/routers/download.py
- **Verification:** `grep "download_url" api/routers/download.py` returns 0 matches
- **Committed in:** 8d7bd41 (Task 2 commit)

---

**Total deviations:** 1 auto-fixed (Rule 2 - missing critical contract enforcement)
**Impact on plan:** Trivial wording change; no functional change. Ensures CDN URL opacity is enforced even at comment level.

## Issues Encountered
None — plan executed cleanly. All acceptance criteria verified.

## Known Stubs
None — both endpoints are fully implemented. File-based streaming fallback is intentional design (not a stub), as it handles sources that provide no direct CDN URL.

## Next Phase Readiness
- All three API endpoints live: `/search`, `/stream/{track_id}`, `/download/{track_id}`
- `musicdl-api.service` ready for `systemctl enable` on cloud server after replacing `MUSICDL_API_KEY`
- Phase 2 (Flutter app) can now target the full API surface: search → track_id → stream/download
- No blockers from this plan

## Self-Check: PASSED

- FOUND: api/routers/stream.py
- FOUND: api/routers/download.py
- FOUND: musicdl-api.service
- FOUND: .planning/phases/01-backend-api/01-03-SUMMARY.md
- FOUND commit: e441893 (feat(01-03): stream endpoint)
- FOUND commit: 8d7bd41 (feat(01-03): download endpoint + systemd)

---
*Phase: 01-backend-api*
*Completed: 2026-03-27*
