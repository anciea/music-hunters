# Requirements: MusicDL Mobile

**Defined:** 2026-03-26
**Core Value:** Users can search and play music from any supported platform through a single, elegant mobile interface

## v1 Requirements

### Backend API

- [x] **API-01**: FastAPI backend exposes `/search` endpoint that accepts keyword query and returns unified results from all sources
- [x] **API-02**: FastAPI backend exposes `/stream` endpoint that returns playable audio URL for a given track
- [x] **API-03**: FastAPI backend exposes `/download` endpoint that returns audio file for local storage

### Playback

- [ ] **PLAY-01**: User can play/pause a track from any screen
- [ ] **PLAY-02**: User can see and scrub a seek bar with current position and total duration
- [ ] **PLAY-03**: User can skip to next/previous track in the queue
- [ ] **PLAY-04**: User can toggle shuffle mode on/off
- [ ] **PLAY-05**: User can cycle repeat mode (off / one / all)
- [ ] **PLAY-06**: Audio continues playing when app is backgrounded
- [ ] **PLAY-07**: Android notification bar shows playback controls (play/pause, next, previous)
- [ ] **PLAY-08**: Headset button controls are supported (play/pause, skip)
- [ ] **PLAY-09**: Audio focus is managed correctly (pause on phone call, duck for notifications)

### Mini Player

- [ ] **MINI-01**: Persistent mini player bar visible at bottom of all screens during playback
- [ ] **MINI-02**: Mini player shows current track title, artist, and play/pause control
- [ ] **MINI-03**: Tapping mini player expands to full-screen player view

### Queue

- [ ] **QUE-01**: User can view the current playback queue
- [ ] **QUE-02**: User can add a track to the queue from search results
- [ ] **QUE-03**: User can remove a track from the queue
- [ ] **QUE-04**: User can reorder tracks in the queue

### Search

- [x] **SRCH-01**: User can search by keyword and see results from all sources
- [x] **SRCH-02**: Each result shows title, artist, album art, duration, and source platform
- [x] **SRCH-03**: User can tap a search result to start playback immediately

### Playlist Management

- [ ] **PLIST-01**: User can create a named playlist
- [ ] **PLIST-02**: User can add a song to a playlist from search results or player
- [ ] **PLIST-03**: User can remove a song from a playlist
- [ ] **PLIST-04**: User can view playlist contents with track list
- [ ] **PLIST-05**: User can delete a playlist (with confirmation)
- [ ] **PLIST-06**: User can reorder tracks within a playlist

### Recent Plays

- [ ] **REC-01**: App records recently played tracks automatically
- [ ] **REC-02**: User can view recent plays list and tap to replay

### Downloads / Offline

- [ ] **DL-01**: User can download a track to local storage from search results or player
- [ ] **DL-02**: Downloaded tracks show download status indicator (downloaded / downloading / not downloaded)
- [ ] **DL-03**: User can browse a downloads library screen showing all locally stored tracks
- [ ] **DL-04**: Downloaded tracks play from local file without network

## v2 Requirements

### Search Enhancements

- **SRCH-10**: Search history with recent queries
- **SRCH-11**: Filter/sort results by source, format, or quality
- **SRCH-12**: Quality/format badge on each result (MP3/FLAC/AAC, bitrate)

### Advanced Playback

- **PLAY-10**: Auto-retry different source if stream fails (source fallback)
- **PLAY-11**: "Available on N platforms" indicator per track

### Library Enhancements

- **PLIST-10**: Import playlist from platform URL (Spotify, Netease, etc.)
- **REC-10**: Play count tracking per track

### Visual Polish

- **UI-10**: Lyrics display during playback
- **UI-11**: Blurred album art as full player background

## Out of Scope

| Feature | Reason |
|---------|--------|
| iOS support | Android first; Flutter enables future expansion |
| User accounts / cloud sync | Personal use tool, local-only storage sufficient |
| Social features | Personal use, not a social platform |
| Equalizer / audio effects | `just_audio` limitation; system-level EQ works |
| Video playback | Audio-only focus; scope creep |
| In-app format conversion | Backend handles format at download time |
| Infinite scroll / recommendations | Users search for what they want; no algorithm |
| Chromecast / audio casting | System Bluetooth sufficient; casting is future |
| Gapless playback | Complex buffering; not critical for search-and-play UX |
| Background download queue | Simple download action sufficient for v1 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| API-01 | Phase 1 | Complete |
| API-02 | Phase 1 | Complete |
| API-03 | Phase 1 | Complete |
| SRCH-01 | Phase 2 | Complete |
| SRCH-02 | Phase 2 | Complete |
| SRCH-03 | Phase 2 | Complete |
| PLAY-01 | Phase 3 | Pending |
| PLAY-02 | Phase 3 | Pending |
| PLAY-03 | Phase 3 | Pending |
| PLAY-04 | Phase 3 | Pending |
| PLAY-05 | Phase 3 | Pending |
| PLAY-06 | Phase 3 | Pending |
| PLAY-07 | Phase 3 | Pending |
| PLAY-08 | Phase 3 | Pending |
| PLAY-09 | Phase 3 | Pending |
| MINI-01 | Phase 3 | Pending |
| MINI-02 | Phase 3 | Pending |
| MINI-03 | Phase 3 | Pending |
| QUE-01 | Phase 3 | Pending |
| QUE-02 | Phase 3 | Pending |
| QUE-03 | Phase 3 | Pending |
| QUE-04 | Phase 3 | Pending |
| DL-01 | Phase 4 | Pending |
| DL-02 | Phase 4 | Pending |
| DL-03 | Phase 4 | Pending |
| DL-04 | Phase 4 | Pending |
| PLIST-01 | Phase 4 | Pending |
| PLIST-02 | Phase 4 | Pending |
| PLIST-03 | Phase 4 | Pending |
| PLIST-04 | Phase 4 | Pending |
| PLIST-05 | Phase 4 | Pending |
| PLIST-06 | Phase 4 | Pending |
| REC-01 | Phase 4 | Pending |
| REC-02 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 34 total
- Mapped to phases: 34
- Unmapped: 0

---
*Requirements defined: 2026-03-26*
*Last updated: 2026-03-26 after roadmap creation — all 34 requirements mapped to phases 1-4*
