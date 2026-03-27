# Phase 4: Library - Context

**Gathered:** 2026-03-27
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase delivers the Library tab experience: downloading tracks for offline use, managing local playlists with full CRUD operations, and automatically recording recently played tracks. All persistent data stored in local SQLite. The Library tab becomes the central hub for the user's personal music collection.

</domain>

<decisions>
## Implementation Decisions

### Download Storage & UX
- App-specific external storage (`getExternalStorageDirectory`) — no permissions needed, survives app data clear
- Circular progress on the download button itself — compact, no extra UI real estate
- Auto-play from local file when tapping a downloaded track in search with subtle "offline" badge — seamless experience
- 3 parallel downloads maximum — balances speed with bandwidth

### Playlist UI & Interaction
- FAB (+) on Library tab → name dialog → empty playlist created — minimal friction
- Long-press context menu adds "Add to Playlist" option → playlist picker bottom sheet — extends existing Phase 3 pattern
- Card grid (2 columns) with cover art mosaic from first 4 tracks — visually rich, standard music app pattern
- AlertDialog with playlist name for delete confirmation — simple, standard Android

### Recent Plays & Library Tab Organization
- 200 recent play entries max — covers ~2 weeks of listening, keeps DB small
- Horizontal scroll of recent 10 at top of Library tab + full list view below — quick access + browsing
- Three sections on Library tab: "Recent Plays" (top), "Playlists" (middle), "Downloads" (bottom) — single scrollable view
- Move to top on replay (no duplicates in recent plays) — cleaner list, always shows latest

### Claude's Discretion
No "You decide" answers — all questions resolved with recommended defaults.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `track_dto.dart` — Freezed model with songName, singers, album, coverUrl, source, ext, trackId
- `track_list_tile.dart` — ListTile widget with onLongPress callback (from Phase 3)
- `search_screen.dart` — Has `_showTrackContextMenu` with Play Now / Play Next / Add to Queue — extend with "Add to Playlist" and "Download"
- `queue_notifier.dart` — QueueNotifier with Riverpod, model for playlist-like state management
- `music_api.dart` — Dio+Retrofit client with /search, /stream, /download endpoints
- `app_scaffold.dart` — 4-tab StatefulShellRoute with Library tab already wired
- Dark theme: #121212 bg, #1E1E1E surfaces, #1DB954 accent

### Established Patterns
- Riverpod with code generation (@riverpod annotation, .g.dart files)
- Freezed for immutable models with JSON serialization
- Long-press context menu for track actions (Phase 3 pattern)
- StreamBuilder for real-time state updates
- CachedNetworkImage for album art

### Integration Points
- Library tab (already exists as empty tab in app_scaffold)
- Backend /download endpoint for fetching audio files
- SQLite database (new — sqflite package, schema with (source, identifier) composite key)
- Long-press context menu on search tiles → add "Download" and "Add to Playlist"
- Full player → add "Download" and "Add to Playlist" action buttons
- QueueNotifier playback → automatic recent plays recording

</code_context>

<specifics>
## Specific Ideas

- SQLite schema uses (source, identifier) composite key — decided in Phase 1 context
- Memory-only queue from Phase 3 remains as-is — playlists are separate persistent concept
- Download endpoint already exists in backend (API-03)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
