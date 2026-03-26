# Feature Landscape: Music Player / Streaming App

**Domain:** Mobile music player with multi-source streaming and offline playback
**Project:** MusicDL Mobile (Flutter + FastAPI)
**Researched:** 2026-03-26
**Overall confidence:** HIGH — music player UX patterns are stable and well-established

---

## Context: What the Backend Already Provides

This Flutter app wraps an existing Python backend. Features marked (backend-ready) have
full server-side implementation. Flutter work is primarily UI + local data management.

- Multi-source search across 21 platforms (Netease, QQ, Spotify, YouTube, Apple Music, Tidal, Qobuz, Deezer, etc.)
- Download with format support (MP3, FLAC, M4A, AAC)
- Playlist URL parsing for multiple platforms
- Metadata tagging and lyrics embedding
- HLS stream download, DRM/Widevine, browser impersonation

---

## Table Stakes

Features users expect in any music app. Absence causes immediate user rejection.

### Playback Core

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Play / Pause | Universal control | Low | Not needed — Flutter `just_audio` | Must work from every screen |
| Seek bar with position / duration | Shows progress, allows scrubbing | Low | Not needed | Requires streaming URL from backend |
| Skip to next / previous track | Standard queue navigation | Low | Not needed | Requires queue state in app |
| Playback queue | Ordered list of upcoming tracks | Medium | Not needed | App-side state management |
| Shuffle mode | Randomize queue | Low | Not needed | Fisher-Yates on local queue |
| Repeat modes (off / one / all) | Loop control | Low | Not needed | Three-state cycle |
| Volume control (via system) | Basic audio control | Low | Not needed | Use Android system volume; do not build in-app slider |

### Background Playback

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Continues when app backgrounded | Core mobile expectation | High | Not needed | Requires `audio_service` package + foreground service |
| Android notification controls | Play/pause/next/prev in notification bar | High | Not needed | MediaSession integration; lock screen too |
| Headset button support | Physical controls | Medium | Not needed | Part of `audio_service` MediaSession |
| Audio focus management | Pauses on calls / other apps | Medium | Not needed | Android AudioManager; `just_audio` handles partially |

### Search

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Keyword search | Core function | Low (UI) | backend-ready | Backend searches all 21 sources concurrently |
| Results show: title, artist, album, duration | Minimum identifying info | Low | backend-ready | `SongInfo` carries all fields |
| Results show cover art | Visual identification | Low | backend-ready | `cover_url` in `SongInfo` |
| Source indicator per result | Multi-source context | Low | backend-ready | Know which platform a track comes from |
| Tap result to play | Direct play from search | Low | Not needed | Immediate streaming via download_url |
| Search history | Repeat queries without retyping | Low | App-side SQLite | Store last N queries |

### Library / Playlist Management

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Create named playlist | Core library function | Low | App-side SQLite | Local creation |
| Add song to playlist | Collect favorites | Low | App-side SQLite | Single tap action |
| Remove song from playlist | Edit collections | Low | App-side SQLite | Swipe to delete |
| View playlist contents | Browse collection | Low | App-side SQLite | Ordered list with cover grid |
| Delete playlist | Cleanup | Low | App-side SQLite | Confirm dialog required |
| Reorder tracks in playlist | Curation | Medium | App-side SQLite | Drag handle UX |

### Offline / Downloaded Music

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Download song to device | Offline availability | Medium | backend-ready | Backend provides file; app saves to local storage |
| Play downloaded song | Core offline feature | Low | Not needed | Read from local file path, no stream needed |
| Show download status on track | Know what's available offline | Low | App-side SQLite | Indicator (downloaded / downloading / not downloaded) |
| Downloads library screen | Browse what's stored locally | Low | App-side SQLite | Filtered view of local tracks |

### Mini Player

| Feature | Why Expected | Complexity | Backend Status | Notes |
|---------|--------------|------------|----------------|-------|
| Persistent mini player bar at bottom | Visible playback state everywhere | Medium | Not needed | Standard pattern in Spotify/Apple Music/YT Music |
| Tap to expand to full player | Navigate to full controls | Low | Not needed | Bottom sheet or slide-up transition |
| Play/pause in mini player | Controls without opening full player | Low | Not needed | Core convenience |
| Track info in mini player | Context without full player | Low | Not needed | Title + artist truncated |

---

## Differentiators

Features that set this app apart. Not expected by users but add real value for this specific use case.

### Multi-Source Unified Search

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Search all 21 platforms simultaneously | No other consumer app does this at scale | Low (UI) | Backend already handles concurrency |
| Per-source result grouping or tagging | User knows where a track can come from | Low | Source badge on result card |
| Filter/sort results by source, quality, or format | Find lossless FLAC specifically | Medium | Filter chips in search UI |
| Prefer FLAC/lossless when available | Power-user audio quality | Low | Sort by format priority; highlight lossless |

### Format / Quality Awareness

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Show audio format on track (MP3 / FLAC / AAC) | Audiophile value; rare in consumer apps | Low | Display ext field from SongInfo |
| Quality badge (128kbps vs lossless) | Helps users choose the best source | Low | Derive from format + bitrate metadata |
| Download in specific format | Choose quality at download time | Medium | Pass format preference to backend API |

### Playback Source Fallback

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Auto-retry different source if stream fails | Reliability other apps can't match | High | App-level fallback: if stream URL errors, re-query backend with same metadata for alt source |
| Show "Available on N platforms" per track | Surfaces redundancy | Medium | Aggregate search results by song identity (name + artist match) |

### Recent Plays

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Recently played list | Quick return to tracks | Low | App-side SQLite; record on play start |
| Play count per track | Optional listening stats | Low | Increment counter in SQLite |

---

## Anti-Features

Things to deliberately NOT build in this milestone. Each has a reason and an alternative.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| User account system / cloud sync | High complexity; not needed for personal use; privacy surface | Use local SQLite for all playlists and history |
| Social features (share, comments, activity feed) | Out-of-scope per PROJECT.md; adds complexity for personal tool | N/A for this project |
| Lyrics display during playback | Explicitly deferred in PROJECT.md | Store LRC files locally at download time; build lyrics screen in a future milestone |
| Equalizer / audio effects | Platform-level complexity; `just_audio` does not support EQ directly | Defer; third-party EQ apps work at system level |
| In-app audio format conversion | Server backend already handles format; conversion on mobile is slow and storage-heavy | Backend converts at download time |
| Video playback (Bilibili, YouTube video mode) | Scope creep; increases complexity substantially | Audio-only; ignore video tracks or extract audio only |
| iOS support | Explicitly deferred in PROJECT.md | Android-first; Flutter enables future iOS without rework |
| Playlist URL import (parse platform playlists into app playlists) | Backend already parses playlist URLs, but surfacing this in the app adds ambiguous UX | Defer to a future milestone after core playback is stable |
| Infinite scroll / discovery / recommendation engine | Requires server-side recommendation logic not in backend | Users search for what they want; no algorithm |
| Background download queue manager | Adds significant UI complexity | Simple "Download" action with status indicator is sufficient for v1 |
| Audio casting (Chromecast, Bluetooth speaker selection) | Requires Android Cast SDK; adds complexity | System handles Bluetooth audio; casting is a future feature |
| Gapless playback | Complex buffering; rarely noticed in search-and-play UX | Standard playback with small natural gap is acceptable |

---

## Feature Dependencies

```
Background Playback (notification controls)
  └── requires: Audio Service (foreground service) BEFORE any playback

Playback Queue
  └── requires: Single-song playback working BEFORE queue logic

Mini Player
  └── requires: Playback queue + song state management

Offline Playback
  └── requires: Download flow + local file path storage in SQLite

Download Flow
  └── requires: Backend /download API endpoint working
  └── requires: Local SQLite schema for tracking downloaded songs

Playlist Management
  └── requires: SQLite schema with playlists + playlist_songs tables
  └── requires: Song identity model (how to reference a song in SQLite)

Search History
  └── requires: SQLite queries table

Recent Plays
  └── requires: SQLite plays table

Format / Quality Display
  └── requires: Backend returning ext + bitrate in search results (SongInfo already has these)

Source Fallback on Stream Error
  └── requires: Full playback working
  └── requires: Search results retaining all candidate SongInfo objects
  └── requires: Per-song multi-source search result grouping
```

---

## MVP Recommendation

Build in this order based on user-visible value and dependency chains:

**Phase 1 — Playback Foundation (highest risk, highest value)**
1. Backend API endpoint: `/search` returning SongInfo list
2. Backend API endpoint: `/stream` or `/download_url` returning playable URL
3. Flutter: `just_audio` + `audio_service` integration (background playback first — hardest problem)
4. Flutter: Full player screen (play/pause, seek, next/prev)
5. Flutter: Mini player bar

**Phase 2 — Search + Library**
6. Flutter: Search screen with results list
7. Flutter: SQLite schema (songs, playlists, playlist_songs, queries, plays)
8. Flutter: Playlist create/edit/delete
9. Flutter: Add to playlist from search results

**Phase 3 — Offline + Polish**
10. Flutter: Download to local storage
11. Flutter: Downloads library screen
12. Flutter: Search history + recent plays
13. Flutter: Format/quality badges

**Defer to future milestone:**
- Lyrics display (backend embeds LRC at download time; display in app later)
- Playlist URL import
- Source fallback on stream error (complex; requires multi-result grouping)
- Audio casting

---

## Material Design UI Patterns for Music Apps

These are established conventions in Material Design 3 and observed in Spotify, Apple Music, and YouTube Music Android implementations. Using them reduces user learning curve.

| Pattern | Implementation Note |
|---------|---------------------|
| Bottom navigation bar (3-5 destinations) | Search / Library / Downloads — standard 3-tab layout |
| Persistent mini player above bottom nav | Standard placement; use `BottomAppBar` or `Scaffold` bottom slot |
| Card-based track list items | Leading thumbnail, title, subtitle (artist), trailing action |
| Bottom sheet for track options | Long-press or "..." menu; "Add to playlist", "Download", "Play next" |
| Expandable full player via bottom sheet or route | Slide-up gesture from mini player |
| Circular progress indicator on download | Per-track progress, not a separate download manager screen |
| Chip filters on search results | Filter by source or format; horizontal scrolling chips |
| Empty state illustrations | For empty playlists and first-run search |
| Dark theme as default | Music apps conventionally dark; use `ThemeMode.dark` as default with light option |
| Album art as full-player background (blurred) | Standard visual pattern in almost all modern music apps |

---

## Sources

- Project context: `.planning/PROJECT.md`, `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/INTEGRATIONS.md`, `.planning/codebase/CONCERNS.md`
- Confidence basis: Music player UX conventions are HIGH confidence from training data — Spotify, Apple Music, YouTube Music, and Pocket Casts patterns are extensively documented and stable
- Material Design 3 component patterns: HIGH confidence from training data (m3.material.io)
- `just_audio` + `audio_service` Flutter ecosystem: MEDIUM confidence from training data (packages are maintained and widely used as of August 2025; verify current versions before implementation)
