---
phase: 02-flutter-shell-search
type: ui-review
audited: 2026-03-27
baseline: 02-UI-SPEC.md
---

# Phase 02 — UI Review

**Audited:** 2026-03-27
**Baseline:** 02-UI-SPEC.md (approved design contract)
**Screenshots:** Not captured (no dev server detected at localhost:3000, 5173, or 8080 — Flutter Android app, code-only audit)

---

## Pillar Scores

| Pillar | Score | Key Finding |
|--------|-------|-------------|
| 1. Copywriting | 3/4 | All spec strings matched exactly; one undocumented snackbar message and source badge tooltip uses raw key not full name |
| 2. Visuals | 3/4 | Clear visual hierarchy with proper focal point; album art semanticLabel missing on TrackListTile as required by accessibility contract |
| 3. Color | 4/4 | All 12 source badge brand colors correct; accent reserved for spec-declared uses only; no off-spec colors |
| 4. Typography | 4/4 | Exactly 4 sizes (12/14/16/20sp) and 2 weights (w400/w600) — perfect spec compliance |
| 5. Spacing | 3/4 | All values on spec scale except one: SizedBox(width: 12) in mini_player_bar.dart is off-scale |
| 6. Experience Design | 3/4 | All 5 search states handled; search bar has no disabled/loading state during active search; album art placeholder uses generic grey instead of platform-colored fallback |

**Overall: 20/24**

---

## Top 3 Priority Fixes

1. **Missing album art semanticLabel in TrackListTile** — Screen readers announce nothing for the 48x48 album art image, breaking the accessibility contract for visually impaired users — Wrap the `CachedNetworkImage` in `Semantics(label: '${track.songName ?? "Unknown"} album art', child: ...)` in `mobile/lib/features/search/widgets/track_list_tile.dart` lines 27-46.

2. **Search bar not disabled during active search** — Users can re-submit a new search while results are loading, causing race conditions between overlapping API calls — In `_SearchScreenState.build()`, read `searchState.isLoading` and set `TextField(enabled: !searchState.isLoading)` or disable the submit action; also set `suffixIcon: null` during loading.

3. **Source badge Tooltip message is raw key not full display name** — "netease" appears as tooltip instead of "Netease Music", degrading the accessibility and hover experience — In `source_badge.dart` line 43, replace `message: source` with a lookup map from source key to full name (e.g., `{'netease': 'Netease Music', 'qq': 'QQ Music', ...}`), falling back to `source` for unknown keys.

---

## Detailed Findings

### Pillar 1: Copywriting (3/4)

All UI-SPEC Copywriting Contract strings are implemented verbatim:

| Spec Element | Expected | Actual | Status |
|---|---|---|---|
| Search placeholder | "Search songs, artists, albums..." | "Search songs, artists, albums..." | PASS |
| Empty state (first launch) heading | "Search for music" | "Search for music" | PASS |
| Empty state (first launch) body | "Type a song, artist, or album above to find music from 21+ sources." | "Type a song, artist, or album above to find music from 21+ sources." | PASS |
| Empty state (no results) heading | "No music found for that search" | "No music found for that search" | PASS |
| Empty state (no results) body | "Try a different search term or check your connection." | "Try a different search term or check your connection." | PASS |
| Error heading | "Couldn't reach the music server" | "Couldn't reach the music server" | PASS |
| Error body | "Check your connection and try again." | "Check your connection and try again." | PASS |
| Error CTA | "Retry Search" | "Retry Search" | PASS |
| Nav labels | Search, Library, Downloads, Settings | Search, Library, Downloads, Settings | PASS |
| Placeholder screens | "Coming soon" | "Coming soon" | PASS |

**Minor deductions:**

- `search_screen.dart:59` — SnackBar message `"Couldn't play this track"` is not in the Copywriting Contract. The spec does not define playback error copy. This is reasonable behavior but undocumented. Low impact.
- `source_badge.dart:43` — `Tooltip(message: source)` passes the raw backend key (e.g., `"netease"`) rather than a human-readable name (e.g., `"Netease Music"`). The accessibility contract specifies `tooltip` set to full source name. This is a copywriting gap for the tooltip surface.

---

### Pillar 2: Visuals (3/4)

**Strengths:**
- Clear visual focal point: search bar is top element, autofocused, with `Icons.search` leading icon as visual anchor.
- Visual hierarchy is correct: title (16sp/w600) > artist (14sp/w400) > duration+badge (12sp/w400) on result cards.
- Icon choices match spec exactly: `Icons.music_note` for first-launch empty state, `Icons.search_off` for no-results, `Icons.wifi_off` for error state.
- Tidal badge correctly applies 1dp white border for contrast on black background (`source_badge.dart:50-52`).
- Mini player bar has correct 1dp top divider (`Color(0xFF2A2A2A)`), matching spec.
- All NavigationDestination icons match spec: search, library_music, download, settings.

**Gaps:**

- **Album art missing semantic label** (`track_list_tile.dart:27-46`): `CachedNetworkImage` does not have a `Semantics` wrapper. The accessibility contract requires `semanticLabel: "${song_name} album art"`. The SUMMARY.md notes this was worked around for `CachedNetworkImage` version incompatibility but the Semantics wrapper was applied inconsistently — it was added to the clear button and mini player art but not to the result tile album art. Screen readers will skip or announce an unhelpful description for result list images.
- **Album art loading placeholder uses generic grey** (`track_list_tile.dart:35-39`): Spec says "platform-colored Container with source icon centered" for fallback. The `placeholder` callback (shown while the image loads) uses `Color(0xFF424242)` regardless of source. Only the `errorWidget` (permanent load failure) correctly uses `badgeColorFor(source)`. During normal image loading, the placeholder is generic grey rather than brand-colored. Visual inconsistency vs. spec.

---

### Pillar 3: Color (4/4)

All color values match the spec palette exactly. No off-spec colors detected.

**Spec palette verification:**

| Token | Value | Used Where | Status |
|---|---|---|---|
| Dominant #121212 | `0xFF121212` | AppBar bg (search_screen.dart:72), scaffold bg (app.dart:30) | PASS |
| Secondary #1E1E1E | `0xFF1E1E1E` | Cards (track_list_tile.dart:25), search fill (search_screen.dart:107), mini player (mini_player_bar.dart:31), nav bar (app.dart:37), shimmer base (shimmer_list.dart:18) | PASS |
| Accent #1DB954 | `0xFF1DB954` | Nav indicator (app.dart:38), shimmer highlight (shimmer_list.dart:19 uses #2A2A2A, not accent — CORRECT per spec), mini player playing icon (mini_player_bar.dart:110), retry button (error_state.dart:50) | PASS |
| Muted #9E9E9E | `0xFF9E9E9E` | Nav icons/labels (app.dart:40/43), search prefix icon (search_screen.dart:88), empty/error body text (empty_state.dart:49, error_state.dart:40) | PASS |
| Muted icon #424242 | `0xFF424242` | Empty state icon (empty_state.dart:32), error icon (error_state.dart:23), art fallback bg (track_list_tile.dart:37, mini_player_bar.dart:50) | PASS |
| Shimmer highlight #2A2A2A | `0xFF2A2A2A` | Shimmer highlight (shimmer_list.dart:19), mini player divider (mini_player_bar.dart:33) | PASS |

All 12 source badge brand colors verified against spec (`source_badge.dart:8-19`) — exact value match.

Accent is not used outside the 4 declared uses. No hardcoded HTML hex strings (`#...`) or `rgb(` patterns found. `Colors.white`, `Colors.white54`, `Colors.white70` are acceptable Flutter semantic color constants for overlay contexts (icon on colored backgrounds) — not off-spec.

**Note on spec ambiguity:** The spec states the search bar leading icon should use "secondary color" (`#1E1E1E`), which would make it invisible against the secondary-filled search bar. The implementation correctly uses `#9E9E9E` (muted), which is the practical readable choice. Score is not deducted for this correction.

---

### Pillar 4: Typography (4/4)

Typography implementation perfectly matches the declared scale.

**Font sizes in use:**

| Size | Weight | Role | Files |
|---|---|---|---|
| 12sp | w400 | Label — duration, badge | source_badge.dart:58, track_list_tile.dart:74 |
| 14sp | w400 | Body — artist, empty/error body | track_list_tile.dart:63, empty_state.dart:47, error_state.dart:38, mini_player_bar.dart:88 |
| 16sp | w600 | Heading — track title, AppBar, retry button, mini player title | track_list_tile.dart:51, error_state.dart:55, mini_player_bar.dart:79 |
| 20sp | w600 | Display — empty/error headings | empty_state.dart:38, error_state.dart:29 |

Exactly 4 sizes, exactly 2 weights (w400, w600). No deviations. No font family overrides found (inherits system Roboto as intended). All role assignments match spec definitions.

---

### Pillar 5: Spacing (3/4)

**Spacing values in use vs. spec scale (4/8/16/24/32/48/64dp):**

| Value | Location | On Scale | Note |
|---|---|---|---|
| 8dp horizontal | search_screen.dart:78 (`EdgeInsets.all(16)` wraps search field — 16 OK) | PASS | |
| 16dp | search_screen.dart:78 (search bar padding) | PASS | md |
| 8dp | source_badge.dart:46 (horizontal badge padding) | PASS | sm |
| 16dp | error_state.dart:16 (horizontal padding) | PASS | md |
| 16dp | error_state.dart:25 (gap after icon) | PASS | md |
| 8dp | error_state.dart:34 (gap after heading) | PASS | sm |
| 24dp | error_state.dart:44 (gap before button) | PASS | lg |
| 8dp | track_list_tile.dart:78 (gap between duration and badge) | PASS | sm |
| 16dp | empty_state.dart:25 (horizontal padding) | PASS | md |
| 16dp | empty_state.dart:34 (gap after icon) | PASS | md |
| 8dp | empty_state.dart:43 (gap after heading) | PASS | sm |
| 16dp horizontal + 8dp vertical | shimmer_list.dart:34 (skeleton tile padding) | PASS | md + sm |
| 16dp | shimmer_list.dart:46 (gap art-to-text) | PASS | md |
| 8dp | shimmer_list.dart:56 (skeleton text gap) | PASS | sm |
| 8dp horizontal | mini_player_bar.dart:36 (bar horizontal padding) | PASS | sm |
| **12dp** | **mini_player_bar.dart:69 (gap art-to-text in mini player)** | **FAIL** | Not in spec scale |

One off-scale value: `SizedBox(width: 12)` in `mini_player_bar.dart:69`. The spec scale has 8dp (sm) and 16dp (md) but not 12dp. Given the 40x40 art and 64dp bar height, 12dp is a reasonable visual choice, but it departs from the declared scale. Low visual impact.

No arbitrary `[Xpx]` or `[Xrem]` Tailwind-style values (Flutter project — N/A). No `double` pixel values outside standard scale.

---

### Pillar 6: Experience Design (3/4)

**State coverage:**

| State | Component | Implemented | Quality |
|---|---|---|---|
| First-launch empty | SearchScreen | Yes — EmptyState(hasSearched: false) with music_note icon | Full |
| Loading | SearchScreen | Yes — ShimmerList (5 skeleton tiles, single-wrapper, ExcludeSemantics) | Full |
| Data with results | SearchScreen | Yes — ListView of TrackListTile | Full |
| Data empty (no results) | SearchScreen | Yes — EmptyState(hasSearched: true) with search_off icon | Full |
| Network/API error | SearchScreen | Yes — ErrorState with retry button | Full |
| Hidden (no playback) | MiniPlayerBar | Yes — SizedBox.shrink() | Full |
| Playing | MiniPlayerBar | Yes — StreamBuilder on playerStateStream | Full |
| Paused | MiniPlayerBar | Yes — play icon, state-reactive | Full |
| Playback failure | SearchScreen | Yes — SnackBar on catch | Full |
| Album art load failure | TrackListTile, MiniPlayerBar | Yes — platform-colored errorWidget | Full |

**Gaps:**

- **Search bar not disabled during loading** (`search_screen.dart:38-41`, `66-148`): The `TextField` remains enabled during active search. A user can submit a second query while the first is in flight. `SearchNotifier.search()` does handle this by calling `state = const AsyncLoading()` then immediately replacing, but rapid successive submissions can produce UI jitter. The spec's interaction state table lists "loading (submit in progress)" as a search bar state, implying it should be visually indicated. No `enabled: false` or visual indicator is applied to the field during `searchState.isLoading`.

- **Album art placeholder (loading state) uses generic grey** (`track_list_tile.dart:34-39`): The `placeholder` callback shown while `CachedNetworkImage` fetches the image uses `Color(0xFF424242)` (neutral grey). The spec says the fallback should be "platform-colored Container with source icon centered." The `errorWidget` (permanent failure) correctly uses `badgeColorFor(source)`. The discrepancy means during initial loading, the brand color context is lost, creating a flash of generic grey before the image or error state resolves.

- **Album art semanticLabel missing** (`track_list_tile.dart:27-46`): As noted in Pillar 2, the accessibility contract (`semanticLabel: "${song_name} album art"`) is not implemented for the result tile album art. This is an experience design gap for users relying on accessibility tools.

---

## Registry Safety

Not applicable. `components.json` not found — this is a Flutter/Dart project, not a shadcn project. Registry audit skipped.

---

## Files Audited

**Primary UI files:**
- `mobile/lib/app.dart` — Theme configuration, GoRouter
- `mobile/lib/shared/app_scaffold.dart` — NavigationBar shell
- `mobile/lib/shared/mini_player_bar.dart` — Mini player bar widget
- `mobile/lib/features/search/search_screen.dart` — Search screen assembly
- `mobile/lib/features/search/search_notifier.dart` — AsyncNotifier state
- `mobile/lib/features/search/widgets/empty_state.dart` — Empty state variants
- `mobile/lib/features/search/widgets/error_state.dart` — Error + retry state
- `mobile/lib/features/search/widgets/shimmer_list.dart` — Skeleton loading
- `mobile/lib/features/search/widgets/source_badge.dart` — Platform badge chip
- `mobile/lib/features/search/widgets/track_list_tile.dart` — Result card

**Supporting files:**
- `mobile/lib/core/providers/player_provider.dart` — AudioPlayer + CurrentTrack providers
- `mobile/lib/features/library/library_screen.dart` — Placeholder
- `mobile/lib/features/downloads/downloads_screen.dart` — Placeholder
- `mobile/lib/features/settings/settings_screen.dart` — Placeholder
- `mobile/lib/main.dart` — ProviderScope entry point

**Reference documents:**
- `.planning/phases/02-flutter-shell-search/02-UI-SPEC.md` — Audit baseline
- `.planning/phases/02-flutter-shell-search/02-01-SUMMARY.md`
- `.planning/phases/02-flutter-shell-search/02-02-SUMMARY.md`
- `.planning/phases/02-flutter-shell-search/02-03-SUMMARY.md`
