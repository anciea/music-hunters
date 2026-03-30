---
status: partial
phase: 04-library
source: [04-VERIFICATION.md]
started: 2026-03-27
updated: 2026-03-27
---

## Current Test

[awaiting human testing]

## Tests

### 1. Download a track and verify icon state changes
expected: Download icon on album art changes to progress indicator then checkmark; track appears in Library > Downloads with 'Offline' badge
result: [pending]

### 2. Play a downloaded track without network
expected: Track starts playing immediately with no network spinner; queue_notifier uses Uri.file path
result: [pending]

### 3. Create playlist, add track, navigate to detail
expected: FAB opens name dialog; playlist card appears in grid; 'Add to Playlist' in context menu; picker shows playlist; 'Added to {name}' SnackBar; detail shows track
result: [pending]

### 4. Reorder tracks via drag handle
expected: Drag handle is tappable; long-press drag moves track; order persists after navigating away and back
result: [pending]

### 5. Swipe-to-delete a track in playlist detail
expected: Red delete background appears; track removed; removal persists in DB
result: [pending]

### 6. Delete a playlist from AppBar
expected: Confirmation dialog with playlist name; tapping 'Delete' pops back to Library; playlist gone
result: [pending]

### 7. Play a track and verify Recent Plays
expected: Track appears as first item in Recent Plays horizontal scroll; tapping it replays
result: [pending]

### 8. Search context menu has 5 items
expected: Long-press shows Play Now, Play Next, Add to Queue, Add to Playlist, Download
result: [pending]

### 9. Full player secondary controls layout
expected: Left side has playlist add + download buttons; download shows correct 3-state
result: [pending]

## Summary

total: 9
passed: 0
issues: 0
pending: 9
skipped: 0
blocked: 0

## Gaps
