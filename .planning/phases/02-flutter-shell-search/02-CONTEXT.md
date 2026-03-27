# Phase 2: Flutter Shell + Search - Context

**Gathered:** 2026-03-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the Flutter Android application shell and search functionality. Users can open the app, search for music by keyword via the Phase 1 backend API, and see results from all 21+ sources displayed as a scrollable list. Tapping a result initiates playback via the /stream endpoint with a minimal player bar. The app shell provides persistent bottom navigation to all main screens (placeholder screens for Library, Downloads, Settings).

</domain>

<decisions>
## Implementation Decisions

### App Shell & Navigation
- 4 bottom nav tabs: Search, Library, Downloads, Settings — maps to milestone phases
- Dark theme only — conventional for music apps, easier on eyes during listening sessions
- State management: Riverpod — type-safe, scalable, handles async data flows well
- API client: Dio + Retrofit — interceptor chain for X-API-Key header injection, typed response models, built-in error handling

### Search UX
- Search triggers on submit button / Enter key press — not debounce/auto-search (21-source search is expensive)
- Loading state: shimmer skeleton cards showing expected layout shape while results load
- Source platform displayed as small colored badge chip on each result card
- Empty states: illustrated friendly empty state with search suggestion on first launch; error state with retry button on failure

### Result Cards & Playback Trigger
- Compact list tiles with small leading album art thumbnail (48x48) — maximize visible results per screen
- Tap result = immediate playback via just_audio using /stream/{track_id} endpoint
- Minimal bottom mini bar appears during playback: shows track title + play/pause control (full player deferred to Phase 3)
- Album art fallback: platform-colored placeholder with source icon when cover art is unavailable

### Claude's Discretion
No "You decide" answers — all questions resolved with recommended defaults accepted by user.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Phase 1 backend API at `api/` — `/search`, `/stream/{track_id}`, `/download/{track_id}` endpoints ready
- `TrackDTO` model: song_name, singers, album, cover_url, duration_s, duration, source, ext, bitrate, codec, file_size, file_size_bytes, track_id
- `SearchResponse` model: tracks list + warnings list
- Track ID format: base64url-encoded `{source}:{identifier}` — decode on backend, opaque to client

### Established Patterns
- API requires `X-API-Key` header on all endpoints (except /health)
- Search returns partial results + warnings for failed sources — client should display available results immediately
- Stream supports HTTP Range requests — compatible with just_audio seek behavior

### Integration Points
- Flutter app connects to backend via HTTPS base URL (configurable)
- All API calls need X-API-Key header injection
- just_audio player consumes /stream/{track_id} URL directly

</code_context>

<specifics>
## Specific Ideas

No specific requirements — user accepted all recommended defaults. Standard Material Design patterns for a music search app.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
