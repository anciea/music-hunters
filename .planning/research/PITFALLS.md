# Domain Pitfalls

**Domain:** Flutter Android music app + Python FastAPI backend (multi-source streaming + offline playback)
**Researched:** 2026-03-26
**Confidence:** HIGH for Android/Flutter audio pitfalls (well-documented ecosystem); MEDIUM for FastAPI-specific streaming patterns (derived from HTTP streaming fundamentals + FastAPI docs knowledge); HIGH for architecture coupling pitfalls (derived from direct codebase analysis)

---

## Critical Pitfalls

Mistakes that cause rewrites or complete feature failure.

---

### Pitfall 1: Background Audio Killed by Android Doze / Battery Optimization

**What goes wrong:** The Flutter app plays music, user locks the screen or switches away, and Android terminates the process within 30-90 seconds. Music stops. Notification controls disappear. This is not a bug — it is Android's default behavior for foreground services not correctly declared.

**Why it happens:** Flutter apps run Dart code in a single isolate. When the app goes to the background, Android's battery optimizer aggressively kills processes that do not hold a `FOREGROUND_SERVICE` with a `mediaPlayback` foreground service type declared in `AndroidManifest.xml`. `just_audio` alone does not set this up. `audio_service` provides the scaffolding, but it requires explicit `AndroidManifest.xml` entries AND the app must not be added to the device's battery optimization exclusion list by the user (cannot be forced, only requested).

**Consequences:** Playback silently stops in background. Users have to grant battery optimization exceptions. MediaSession notifications disappear. If the audio isolate and UI isolate lose sync, queue state is corrupted.

**Prevention:**
- Use `audio_service` (not `just_audio` standalone) from day one. Wrapping `just_audio` inside an `AudioHandler` is non-trivial to add after the fact.
- Declare `<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />` and `<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />` in `AndroidManifest.xml`.
- Declare the service with `android:foregroundServiceType="mediaPlayback"` inside `<service>`.
- During first launch, prompt user to exempt the app from battery optimization using `permission_handler` or `battery_plus`.

**Detection (warning signs):**
- Music stops exactly ~1 minute after screen lock.
- No crash log — just silent process death.
- Notification disappears when returning to the app.

**Phase to address:** Audio playback phase (Phase 1 or 2). Cannot retrofit this later without restructuring the entire audio architecture.

---

### Pitfall 2: Streaming URL Expiry During Playback

**What goes wrong:** The backend fetches a time-limited signed URL from a music source (Tidal, Qobuz, Spotify, Apple Music, etc.). The URL is returned to the Flutter app. The app begins playback. If the song is long or the user pauses for several minutes, the URL expires and the stream returns HTTP 403 or 401. Playback silently stalls.

**Why it happens:** Most CDN-backed music sources issue signed streaming URLs valid for 5-30 minutes. The existing Python backend already handles this for downloads (it fetches + saves immediately), but the streaming scenario is different: the URL must remain valid for the entire song duration plus any pause time.

**Codebase evidence:** `SongInfo.download_url` is a plain string. There is no TTL or expiry metadata carried alongside it. `AudioLinkTester` validates the URL at fetch time but does not track expiry. `BaseMusicClient._download()` starts downloading immediately after URL fetch, which avoids expiry. Streaming to a mobile client introduces a gap between URL fetch and consumption.

**Consequences:** Mid-song failures, especially on long tracks (classical, podcasts, audiobooks). Difficult to reproduce in development (short test tracks rarely expire). Users see frozen progress bars with no error message.

**Prevention:**
- The FastAPI streaming endpoint should proxy audio bytes directly rather than returning a raw CDN URL to Flutter. The backend fetches from the CDN and streams bytes to the client — the URL never touches Flutter.
- If raw URL passthrough is used for performance, the endpoint must return a URL validity window (`expires_at` epoch) and the Flutter player must re-fetch the URL before it expires (e.g., 60 seconds before expiry).
- Implement a `refresh_stream_url` endpoint that returns a fresh URL without restarting playback.

**Detection (warning signs):**
- Playback works perfectly on short test tracks (< 3 min) but fails on long tracks.
- HTTP 403 errors appear in network logs mid-stream.
- Failures are intermittent and time-dependent, not deterministic.

**Phase to address:** API design phase (Phase 1). The decision of "proxy vs pass-through URL" is architectural and affects every source adapter integration.

---

### Pitfall 3: Android `WRITE_EXTERNAL_STORAGE` / Scoped Storage Breakage

**What goes wrong:** Downloads fail silently on Android 10+ (API 29+) because the app writes to arbitrary paths that are no longer writable. Or the app requests `WRITE_EXTERNAL_STORAGE` which is ignored on Android 13+ (API 33+). Files appear to be saved but are not visible in the file manager.

**Why it happens:** Android introduced Scoped Storage in Android 10 and enforced it in Android 11. Apps cannot write to arbitrary paths on external storage. Downloads must go to `getExternalFilesDir()` (app-private, no permission needed) or use the `MediaStore` API (requires `MediaStore.Audio` inserts for music to appear in the system music library).

**Consequences:** Downloads work in debug on emulator (API 28 default), fail on production devices. Files saved to wrong location are inaccessible after app uninstall. Music does not appear in the Android system media scanner.

**Prevention:**
- Use `path_provider` package to get `getApplicationDocumentsDirectory()` or `getExternalStorageDirectory()` — never hardcode paths.
- For files intended to appear in the system music library, use `MediaStore` via platform channels or the `media_store_plus` plugin.
- Test on a physical device running Android 13+ from day one, not only on emulator.
- Do NOT request `WRITE_EXTERNAL_STORAGE` on API 33+ — it is automatically denied and triggers a permission dialog that confuses users.

**Detection (warning signs):**
- Downloads succeed on debug build / emulator but fail on release build on physical device.
- `File.writeAsBytes()` returns no error but file is not found afterward.
- `WRITE_EXTERNAL_STORAGE` permission is always denied without dialog.

**Phase to address:** Download/offline phase. Must be addressed before implementing the download feature.

---

### Pitfall 4: Blocking the FastAPI Event Loop with Synchronous Music Client Code

**What goes wrong:** The FastAPI backend routes call `MusicClient.search()` or `MusicClient.download()` directly. These methods use `requests` (a synchronous HTTP library), `ThreadPoolExecutor`, file I/O, and CPU-bound parsing. Calling them directly from an `async def` endpoint blocks the entire event loop. Under concurrent mobile requests, the server becomes unresponsive.

**Why it happens:** The existing Python codebase is entirely synchronous (`requests`, blocking file writes, `pickle.dump`). FastAPI is async at the framework level. The two are incompatible without explicit isolation. A single blocked event loop means all other requests — including health checks and other users — are frozen.

**Codebase evidence:** `BaseMusicClient.search()` and `BaseMusicClient.download()` are synchronous methods using `ThreadPoolExecutor` internally. `_savetopkl()` calls `pickle.dump()` synchronously. `AudioLinkTester` makes blocking `requests.get()` calls. None of this is `async`-aware.

**Consequences:** Server appears hung under load. Timeout errors on mobile client. Two simultaneous search requests cause the second to wait for the first to complete entirely.

**Prevention:**
- Wrap all `MusicClient` calls in `asyncio.get_event_loop().run_in_executor(None, sync_function, *args)` or use `fastapi.concurrency.run_in_threadpool()`.
- Never call `requests`-based code directly inside `async def` endpoints.
- Use `asyncio.run_in_executor` with a bounded `ThreadPoolExecutor` (not the default unbounded one) to prevent spawning thousands of threads under search load.
- Long-running searches should use background tasks (`BackgroundTasks`) with a job ID returned immediately, polled by the client.

**Detection (warning signs):**
- Server responds immediately to the first search, but a second concurrent request from a different client hangs.
- `asyncio` debug mode logs warnings about coroutines taking > 0.1s.
- `uvicorn` worker processes spike CPU but the event loop metrics show zero async tasks — all work is in threads.

**Phase to address:** Backend API phase (Phase 1). Wrapping strategy must be established in the first endpoint implementation.

---

### Pitfall 5: SQLite Concurrent Write Contention from UI + Download Threads

**What goes wrong:** The Flutter app writes to SQLite (via `sqflite`) from multiple places simultaneously: saving a new playlist while a download completes and updates its local path, while the UI reads the playlist list. On Android, SQLite in WAL mode handles concurrent reads, but concurrent writes serialize and can cause `SQLITE_BUSY` errors that manifest as silent failures in `sqflite`.

**Why it happens:** `sqflite` in Flutter wraps Android's SQLite. By default it uses a single database connection. If the app opens multiple transactions from different `Future` chains without a proper serialization layer, write operations collide.

**Consequences:** Playlist state corrupts silently. Downloaded song records are partially written. "Local path" field remains null even after successful download, making the app re-stream songs that are already downloaded.

**Prevention:**
- Use a single `Database` singleton, never open the database file twice.
- Route all writes through a single repository class with a sequential write queue (Dart `Queue` with a lock, or a stream-based command pattern).
- Enable WAL mode explicitly: `db.execute('PRAGMA journal_mode=WAL')` after opening.
- Use database migrations with version tracking from the start — adding columns to an existing table post-launch is painful without migrations.

**Detection (warning signs):**
- Playlist occasionally shows 0 songs after adding songs.
- Download status does not update in UI even though file exists on disk.
- `sqflite` debug logs show `SQLITE_BUSY` or transaction rollback errors.

**Phase to address:** Local storage phase. Must be designed before implementing both playlist management and download management (they share the database).

---

## Moderate Pitfalls

Mistakes that cause significant rework but not full rewrites.

---

### Pitfall 6: Search Result Inconsistency Across 21 Sources

**What goes wrong:** The Flutter UI receives search results from 21+ sources, each with different field completeness. Some sources return `duration_s: null`, some return `cover_url: null`, some return `bitrate: null`. If the UI assumes all fields are present, it throws null pointer exceptions or renders broken cards.

**Codebase evidence:** `SongInfo` dataclass uses `Optional[T]` for nearly every field. `duration`, `bitrate`, `codec`, `cover_url`, `lyric` are all `Optional`. Third-party scrapers in `musicdl/modules/thirdpartysites/` are especially sparse — they provide minimal metadata.

**Prevention:**
- Define a strict JSON schema for the FastAPI response. Never pass `null` for fields the UI consumes without a defined fallback.
- The Dart model class must use null-safe getters with fallback values: `song.duration ?? 'Unknown'`, `song.coverUrl ?? defaultCoverAsset`.
- The API should normalize sparse results server-side: fill in defaults, remove entirely broken results (no `download_url`, no `song_name`).

**Phase to address:** API design + UI phase.

---

### Pitfall 7: HLS Streams Cannot Be Proxied as Simple Audio URLs

**What goes wrong:** The existing backend downloads HLS streams by assembling all segments locally (`HLSDownloader`). For live streaming (not download), this approach does not work — the Flutter `just_audio` player expects either a direct HTTP audio URL or an HLS `.m3u8` manifest URL. If the backend returns a `.m3u8` URL that requires custom headers (cookies, authorization), `just_audio` cannot add those headers to segment requests — only the manifest fetch can be customized.

**Codebase evidence:** `HLSDownloader` handles AES-128 encrypted segments, byte ranges, key fetching. This is server-side logic that `just_audio`'s built-in HLS player does not replicate. Sources using HLS (Tidal, some aggregators) may require auth headers on every segment request, not just the manifest.

**Consequences:** HLS songs from auth-gated sources (Tidal HiFi, Qobuz) will fail to stream even if the `.m3u8` URL is valid, because segment requests lack authorization. Silent 403 errors on every segment.

**Prevention:**
- For HLS sources that require per-segment auth, the backend must proxy the stream: fetch the manifest, rewrite segment URLs to point back to the FastAPI server (which adds auth headers), then serve the rewritten manifest to Flutter.
- OR: Use the download path for HLS sources in "streaming" mode — download to a temp file on the server, serve via range-request HTTP once download begins (progressive serving).
- Track which sources use HLS vs HTTP in the source registry and route accordingly.

**Phase to address:** Streaming implementation phase.

---

### Pitfall 8: Download URL Regeneration is Source-Specific and Not Idempotent

**What goes wrong:** A song's `download_url` is often ephemeral — it is generated fresh during the `search()` call and expires. If the Flutter app caches a `SongInfo` response and tries to use `download_url` hours later (for a deferred download), the URL is stale.

**Codebase evidence:** `BaseMusicClient._search()` extracts download URLs inline during search. `download_url_status` is tested via `AudioLinkTester` at search time. There is no `refresh_download_url()` method on `BaseMusicClient`. Some sources (YouTube, Spotify via third-party) regenerate URLs per-request.

**Prevention:**
- Do not cache raw `download_url` values in the Flutter client longer than a session.
- The FastAPI `POST /download` endpoint should accept a song identifier (source + track ID), re-fetch a fresh URL internally, then begin the download — not accept a pre-fetched URL from the client.
- Store source + track ID in SQLite, not the raw download URL. Re-resolve when needed.

**Phase to address:** Download architecture phase.

---

### Pitfall 9: CORS and HTTPS Mixed-Content Blocking

**What goes wrong:** The FastAPI backend is deployed on a cloud server (HTTPS). The Flutter Android app makes requests to it fine. But some streaming URLs returned by the backend point to CDN domains that are HTTP (not HTTPS) or use self-signed certificates. Android 9+ (API 28+) blocks cleartext HTTP traffic by default. Songs from certain aggregator sources (third-party scrapers) may use HTTP-only CDN endpoints.

**Codebase evidence:** `musicdl/modules/thirdpartysites/` scrapers and `musicdl/modules/common/` aggregators are unofficial and may not use HTTPS for their download links.

**Prevention:**
- Add a `network_security_config.xml` in Android resources that explicitly allows cleartext traffic only for known CDN domains, or use the proxy approach (all traffic routed through the FastAPI backend, which handles HTTP → HTTPS bridging).
- The proxy approach (backend serves audio bytes, client only talks to the FastAPI HTTPS endpoint) eliminates this problem entirely.
- Audit third-party source URLs in the codebase for HTTP vs HTTPS before deciding on proxy vs passthrough architecture.

**Phase to address:** API architecture phase (before first streaming implementation).

---

### Pitfall 10: MediaSession / Notification Controls Require Exact Metadata Fields

**What goes wrong:** Android notification controls (lock screen player, notification bar) require artwork, title, and artist to be set on the `MediaItem` or `MediaMetadata`. If these are null or not set before playback begins, the notification appears blank or does not appear at all. On some Android OEM skins (MIUI, EMUI, One UI), notification controls are disabled by default for new apps.

**Prevention:**
- Always populate `MediaItem(id: ..., title: ..., artist: ..., artUri: ...)` before calling `audioPlayer.setAudioSource()`.
- Pre-fetch cover art URL and set it on `MediaMetadata` — do not wait for playback to start.
- Include guidance in app onboarding for users on MIUI/EMUI to enable notification controls for the app.
- Use `audio_service`'s `MediaItem` rather than `just_audio`'s raw `AudioSource` to ensure `MediaSession` metadata is always populated.

**Phase to address:** Audio player + notification phase.

---

### Pitfall 11: Song Identity Across Sources Has No Stable Key

**What goes wrong:** The same song appears across multiple sources (Netease, QQ Music, aggregators). The `identifier` field in `SongInfo` is source-specific (e.g., Netease song ID). There is no cross-source canonical ID. If a user adds a Netease result to a playlist and the Netease source goes down, the playlist entry becomes unresolvable. Deduplication in the Flutter UI also becomes complex.

**Codebase evidence:** `BaseMusicClient._removeduplicates()` deduplicates by `song_info.identifier` within a single source. Cross-source deduplication does not exist. `SongInfo.source` and `SongInfo.identifier` together form a composite key, but there is no normalization layer.

**Prevention:**
- The SQLite schema must store `(source, identifier)` as a composite key for downloaded songs.
- For playlist entries that are "undownloaded" (stream-only), accept that they may become unresolvable if the source changes; design the UX to gracefully show "unavailable" rather than crash.
- Consider a lightweight fingerprint (song_name + singers + duration_s normalized) as a fuzzy match key for cross-source identification — but keep it as a secondary index, not the primary key.

**Phase to address:** Local database schema phase.

---

## Minor Pitfalls

Mistakes that cause friction but are fixable without major rework.

---

### Pitfall 12: `rich.Progress` Output Leaks Into API Responses

**What goes wrong:** The existing backend uses `rich.Progress` with colored console output during search and download. If this output is not suppressed in the FastAPI context, it writes ANSI escape codes to `stdout`, which can pollute structured log output in cloud environments and interfere with uvicorn's log formatting.

**Prevention:**
- Pass `disable_print=True` to all `MusicClient` and `BaseMusicClient` instances in the FastAPI context.
- Redirect `LoggerHandle` output to Python's `logging` module using a custom handler, rather than direct `print()`/`console.print()` calls.

**Phase to address:** FastAPI setup phase.

---

### Pitfall 13: `fake_useragent` Makes HTTP Calls on First Use

**What goes wrong:** `BaseMusicClient.__init__()` calls `UserAgent().random` three times (for search, download, parse headers). `fake_useragent` fetches a remote user agent database from `useragentstring.com` on first use if the local cache is stale. In a containerized backend, this outbound HTTP call during server startup may fail (firewall rules, no internet access for the container), causing `BaseMusicClient` instantiation to fail.

**Codebase evidence:** Lines 65 in `base.py`: `self.default_search_headers = {'User-Agent': UserAgent().random}` called unconditionally in `__init__`.

**Prevention:**
- Pre-populate the `fake_useragent` cache file during Docker image build.
- Or set `UserAgent(fallback='Mozilla/5.0 ...')` with a hardcoded fallback so network failure does not raise an exception.
- Or replace `fake_useragent` with a static list of recent user agents for the backend context (browser impersonation matters for the source clients, not for the server's own identity).

**Phase to address:** Backend containerization / deployment phase.

---

### Pitfall 14: Seek Accuracy Differs Between HTTP and HLS Sources

**What goes wrong:** HTTP sources (direct MP3/FLAC/M4A URL) support byte-range seeking — `just_audio` can seek precisely to any timestamp. HLS sources have segment-level granularity (typically 6-10 second segments). Seeking to second 47 of an HLS stream may actually jump to second 42 (start of the segment). Users notice the seek bar does not land exactly.

**Prevention:**
- Accept this as a known limitation for HLS sources. Do not promise sub-second seek accuracy.
- Display seek position as an approximation for HLS sources; show a "segment-level" seek indicator if needed.
- Prefer HTTP sources over HLS sources when both are available for the same song (already partially done by `AudioLinkTester`'s URL validation logic).

**Phase to address:** Audio player implementation phase.

---

### Pitfall 15: `pickle` Serialization in Backend is a Security and Versioning Risk

**What goes wrong:** The existing codebase uses `pickle.dump` / `pickle.load` to persist `SongInfo` objects (`_savetopkl()`). In the CLI context this is fine. If the FastAPI backend ever uses these pickle files as a cache (to avoid re-searching), deserialization of pickled data from untrusted sources is a known arbitrary code execution vector. Additionally, if `SongInfo` dataclass fields change between backend deployments, old pickle files will fail to load.

**Codebase evidence:** `_savetopkl()` in `base.py` writes `search_results.pkl` and `download_results.pkl`. These are currently file-system artifacts on the server.

**Prevention:**
- Do NOT expose pickle files via API endpoints.
- Use JSON serialization (via `SongInfo.todict()` + `SongInfo.fromdict()`) for any data shared with the mobile client — `SongInfo` already has these methods.
- For server-side caching, use Redis or a simple JSON file cache — never deserialize untrusted pickle data.

**Phase to address:** Backend API phase.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| FastAPI endpoint scaffolding | Blocking event loop (Pitfall 4) | Use `run_in_threadpool` wrapper from day one |
| Audio playback setup | Background audio killed (Pitfall 1) | Integrate `audio_service` before any playback feature |
| Streaming URL design | URL expiry mid-playback (Pitfall 2) | Decide proxy vs passthrough architecture before first endpoint |
| Local download feature | Scoped Storage failure (Pitfall 3) | Use `path_provider`, test on Android 13 device |
| Local database schema | Concurrent write contention (Pitfall 5) | Singleton DB + WAL mode + migration system |
| HLS source playback | Segment auth failure (Pitfall 7) | Detect HLS sources, implement manifest rewrite or temp download |
| Download queue | Stale URLs (Pitfall 8) | Store source+ID only, re-resolve on download |
| Notification controls | Blank MediaSession (Pitfall 10) | Always populate MediaItem metadata before play |
| Playlist persistence | No stable cross-source ID (Pitfall 11) | Composite (source, identifier) key in schema |
| Backend deployment | `fake_useragent` network call on init (Pitfall 13) | Cache UA database in Docker image |
| Search result rendering | Null field crashes (Pitfall 6) | Define strict nullable schema, Flutter null-safe getters |

---

## Sources

- Direct codebase analysis: `musicdl/modules/sources/base.py`, `musicdl/modules/utils/data.py`, `musicdl/modules/utils/hls.py`, `musicdl/modules/utils/misc.py`
- Android Scoped Storage: https://developer.android.com/about/versions/11/privacy/storage (HIGH confidence — well-documented Android API behavior)
- Android Foreground Services: https://developer.android.com/guide/components/foreground-services (HIGH confidence — Android platform behavior)
- `audio_service` package architecture: https://pub.dev/packages/audio_service (HIGH confidence — package documentation knowledge)
- `just_audio` Android limitations: https://pub.dev/packages/just_audio (HIGH confidence — package documentation knowledge)
- FastAPI sync/async: https://fastapi.tiangolo.com/async/ (HIGH confidence — FastAPI official docs)
- `sqflite` concurrent writes: https://pub.dev/packages/sqflite (MEDIUM confidence — known community issue, single-connection constraint)
- HLS segment authentication: RFC 8216, MPEG-DASH spec behavior (HIGH confidence — protocol-level behavior)
- `fake_useragent` remote fetch: https://pypi.org/project/fake-useragent/ (MEDIUM confidence — known behavior from package source)
