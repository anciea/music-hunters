# Roadmap: MusicDL Mobile

## Overview

The existing Python musicdl library (21 platform adapters, HLS/DRM support) is wrapped by a FastAPI adapter backend, then consumed by a Flutter Android app. Work proceeds in four coarse phases: first the backend API layer is validated, then the Flutter app shell and search loop are confirmed end-to-end, then the audio playback stack is built from the ground up with background service support, and finally the local library (downloads, playlists, recent plays) is completed to deliver the full offline-capable experience.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Backend API** - FastAPI adapter wrapping Python musicdl; search, stream, download endpoints live and callable
- [x] **Phase 2: Flutter Shell + Search** - Flutter project scaffold, navigation shell, and working search screen talking to Phase 1 API (completed 2026-03-27)
- [ ] **Phase 3: Audio Playback** - Full audio stack (just_audio + audio_service), mini player, full player screen, queue management, background playback
- [ ] **Phase 4: Library** - Downloads to local storage, offline playback, playlists (CRUD + reorder), and recent plays

## Phase Details

### Phase 1: Backend API
**Goal**: The Python musicdl library is accessible as a REST API that a Flutter client can call
**Depends on**: Nothing (first phase)
**Requirements**: API-01, API-02, API-03
**Success Criteria** (what must be TRUE):
  1. A search query returns a JSON list of tracks with title, artist, album art URL, duration, and source platform
  2. A stream request for a track returns a proxied audio byte stream that a media player can consume without receiving raw CDN URLs
  3. A download request returns the audio file in the requested format (MP3/FLAC/M4A/AAC)
  4. All endpoints require a valid API key and reject unauthenticated requests
  5. Server is accessible over HTTPS from an Android emulator running on a development machine
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — api/ scaffold: FastAPI app, auth, models, utils (TrackDTO, encode/decode, run_sync)
- [x] 01-02-PLAN.md — GET /search endpoint with TTLCache, SongInfo->TrackDTO mapping
- [x] 01-03-PLAN.md — GET /stream/{track_id} (httpx proxy + Range forwarding) and GET /download/{track_id} (FileResponse + BackgroundTask cleanup); systemd service unit

### Phase 2: Flutter Shell + Search
**Goal**: Users can open the app, search for music by keyword, and see results from all sources
**Depends on**: Phase 1
**Requirements**: SRCH-01, SRCH-02, SRCH-03
**Success Criteria** (what must be TRUE):
  1. User can type a keyword and receive a scrollable list of results from all 21 sources
  2. Each result card displays track title, artist name, album art, duration, and source platform badge
  3. The app shell has persistent bottom navigation and all main screens are reachable
  4. Tapping a search result begins playback (audio starts, even if player UI is minimal at this stage)
**Plans**: 3 plans
**UI hint**: yes

Plans:
- [x] 02-01-PLAN.md — Flutter project scaffold: pubspec, Freezed models, Dio+Retrofit API client, go_router 4-tab shell, dark theme
- [x] 02-02-PLAN.md — Search screen: AsyncNotifier, result list tiles, source badges, shimmer loading, empty/error states
- [x] 02-03-PLAN.md — Tap-to-play via just_audio /stream endpoint, mini player bar with play/pause control

### Phase 3: Audio Playback
**Goal**: Users can play music with full controls, background audio, notification bar integration, and queue management
**Depends on**: Phase 2
**Requirements**: PLAY-01, PLAY-02, PLAY-03, PLAY-04, PLAY-05, PLAY-06, PLAY-07, PLAY-08, PLAY-09, MINI-01, MINI-02, MINI-03, QUE-01, QUE-02, QUE-03, QUE-04
**Success Criteria** (what must be TRUE):
  1. User can play/pause, seek, skip next/previous, toggle shuffle, and cycle repeat from the full player screen
  2. Audio continues playing after the user presses the home button or locks the screen
  3. The Android notification bar shows album art, track title, and play/pause/skip controls that function when tapped
  4. A persistent mini player bar appears at the bottom of every screen during playback showing title, artist, and play/pause control, and tapping it opens the full player
  5. User can view the playback queue, add tracks to it, remove tracks, and reorder them
**Plans**: TBD
**UI hint**: yes

### Phase 4: Library
**Goal**: Users can download tracks for offline use, manage local playlists, and review recently played tracks
**Depends on**: Phase 3
**Requirements**: DL-01, DL-02, DL-03, DL-04, PLIST-01, PLIST-02, PLIST-03, PLIST-04, PLIST-05, PLIST-06, REC-01, REC-02
**Success Criteria** (what must be TRUE):
  1. User can tap a download button on a track and the file is saved to local storage; the track plays back from the local file with no network request
  2. Every track in search results and the player shows a visual indicator of its download state (not downloaded / downloading / downloaded)
  3. User can create a named playlist, add and remove songs, reorder tracks within it, view its contents, and delete it with a confirmation prompt
  4. The app automatically records every played track and the user can view a recent plays list and tap any entry to replay it
  5. A Downloads library screen shows all locally stored tracks browsable without network
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Backend API | 3/3 | Complete |  |
| 2. Flutter Shell + Search | 3/3 | Complete   | 2026-03-27 |
| 3. Audio Playback | 0/? | Not started | - |
| 4. Library | 0/? | Not started | - |
