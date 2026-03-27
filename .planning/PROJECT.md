# MusicDL Mobile

## What This Is

A Flutter Android application that provides a unified music experience across 21+ music platforms (Netease, QQ Music, Spotify, YouTube, Apple Music, Tidal, Qobuz, Deezer, etc.). The app connects to a Python FastAPI backend deployed on a cloud server, which handles music search, parsing, and streaming. Users can search songs across all platforms, manage local playlists, and enjoy seamless music playback with background audio and notification controls.

## Core Value

Users can search and play music from any supported platform through a single, elegant mobile interface — no platform switching, no friction.

## Requirements

### Validated

- ✓ Multi-platform music search across 21+ sources — existing
- ✓ Music download with format support (MP3, FLAC, M4A, AAC) — existing
- ✓ Playlist URL parsing for multiple platforms — existing
- ✓ Metadata tagging and lyrics embedding — existing
- ✓ HLS stream download support — existing
- ✓ DRM/Widevine protected content support — existing
- ✓ Browser impersonation for API access — existing

### Active

- ✓ FastAPI backend wrapping existing Python music client logic — Validated in Phase 1: Backend API
- [ ] Flutter Android app with Material Design UI
- [ ] Cross-platform music search with unified results display
- [ ] Hybrid music playback (online streaming + local download)
- [ ] Background audio playback with notification bar controls
- [ ] Local playlist management (create, edit, delete playlists)
- [ ] Song download to local storage for offline playback
- [ ] Music player with standard controls (play/pause, next/prev, seek, shuffle, repeat)
- [ ] Search history and recent plays

### Out of Scope

- iOS support — focus on Android first, Flutter enables future iOS expansion
- User account system / cloud sync — playlists stored locally only
- Social features (sharing, comments) — personal use tool
- Lyrics display during playback — may add in future milestone
- Equalizer / audio effects — keep initial scope simple

## Context

- **Existing codebase**: Mature Python music downloader with 21 platform adapters, modular client-adapter architecture with `BaseMusicClient` base class and `MusicClientBuilder` registry
- **Architecture decision**: Python backend (FastAPI) + Flutter frontend — leverages existing Python music client logic without rewriting, Flutter provides native Android experience
- **Key dependencies**: requests, curl_cffi (browser impersonation), ytmusicapi, aigpy (TIDAL), mutagen (metadata), pywidevine (DRM)
- **Deployment**: Backend on cloud server, accessible via HTTPS API
- **Storage**: Local SQLite database for playlists and downloaded music metadata on Android device

## Constraints

- **Tech stack**: Flutter (frontend) + Python FastAPI (backend) — decided during initialization
- **Platform**: Android only for v1 — personal use on user's phone
- **Backend deployment**: Cloud server — must handle API requests from mobile client
- **Storage**: Local-only playlists (SQLite) — no server-side user data
- **Network**: App requires network for search/streaming, offline mode for downloaded songs only

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter over Native Android | Cross-platform potential for future iOS, strong Material Design support, single codebase | — Pending |
| Python FastAPI backend | Reuse existing 21 platform adapters without rewriting in Dart, FastAPI offers async support and auto API docs | — Pending |
| Local-only playlists (SQLite) | Simplicity, no need for cloud infrastructure for personal use | — Pending |
| Hybrid playback mode | Balance between storage usage and offline availability | — Pending |
| Material Design UI | Clean, modern look following Google design guidelines | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-27 after Phase 1: Backend API completion*
