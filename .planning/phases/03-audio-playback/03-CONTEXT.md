# Phase 3: Audio Playback - Context

**Gathered:** 2026-03-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the full audio playback experience: full-screen player with controls, background audio via audio_service, Android notification bar integration, and queue management. Users can play/pause, seek, skip, shuffle, repeat from the full player screen. Audio persists when backgrounded. A persistent mini player bar (enhanced from Phase 2) provides quick access to the full player.

</domain>

<decisions>
## Implementation Decisions

### Full Player Screen Design
- Full-width dominant album art (~300dp centered, Spotify-style) — maximizes visual impact, conventional for music apps
- Solid dark background (#121212) — consistent with app theme, simpler, no performance overhead
- Slide-up bottom sheet (DraggableScrollableSheet) for mini-to-full player transition — smooth gesture-based, no route push needed
- Source badge + quality info (format/bitrate when available) shown on full player — useful for multi-source app

### Queue Management UX
- Queue accessed via icon button on full player that opens a bottom sheet list — standard pattern, keeps player in view
- Long-press context menu on search result tiles for "Play Next" / "Add to Queue" — avoids cluttering tile UI
- Single track playback only — user taps one track, it plays. No auto-fill from search results into queue
- Memory-only queue (Riverpod state) — lost on app kill. Simple for v1, SQLite persistence deferred

### Playback Behavior
- Stop after last track in queue when not repeating — user explicitly adds what they want
- Auto-retry stream once on failure, then show error SnackBar with "Retry" action — handles transient CDN failures
- Live preview timestamp while scrubbing seek bar — shows position label above thumb during drag
- MediaStyle notification with large album art + play/pause, skip prev, skip next — Android standard

### Claude's Discretion
No "You decide" answers — all questions resolved with recommended defaults accepted by user.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `player_provider.dart` — `audioPlayerProvider` (keepAlive AudioPlayer singleton) and `currentTrackProvider` (CurrentTrack Notifier) already exist
- `mini_player_bar.dart` — 64dp bar with album art, title, artist, StreamBuilder play/pause toggle. Needs enhancement: tap-to-expand, progress indicator
- `app_scaffold.dart` — MiniPlayerBar already integrated above NavigationBar in Column layout
- `track_dto.dart` — Freezed model with songName, singers, album, coverUrl, durationS, duration, source, ext, bitrate, codec, trackId
- `source_badge.dart` — 12 platform brand colors, reusable in full player
- `music_api.dart` — Dio+Retrofit API client with /search and /stream endpoints

### Established Patterns
- Riverpod with code generation (@riverpod annotation, .g.dart files)
- Dark theme: #121212 background, #1E1E1E surfaces, #1DB954 accent
- StreamBuilder for real-time player state (used in mini player bar)
- just_audio AudioSource.uri with X-API-Key header for streaming

### Integration Points
- `audio_service` AudioHandler must wrap existing just_audio player — critical decision from STATE.md: integrate from Phase 3 start, cannot retrofit
- Mini player bar tap → expand to full player (DraggableScrollableSheet)
- Queue state → feeds just_audio ConcatenatingAudioSource
- Search screen long-press → add to queue interaction
- Full player screen → new route or overlay accessible from mini player

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. Follow Spotify-like conventions for music player UX.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>
