import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/queue_notifier.dart';
import '../../core/providers/player_provider.dart';

/// Full queue bottom sheet with reorder and remove support.
///
/// Shows the current playback queue with:
/// - Currently-playing indicator (accent dot for active track)
/// - Drag-to-reorder handles
/// - Remove buttons
/// - Empty state with guidance text
///
/// Open via [QueueBottomSheet.show].
class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  /// Opens the queue bottom sheet as a modal.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => const QueueBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider);
    final handler = ref.read(audioHandlerProvider);

    return Semantics(
      container: true,
      label: 'Playback queue',
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header row: "Queue" + "(N tracks)"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Queue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${queue.length} tracks)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),

            // Queue content
            Expanded(
              child: queue.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.queue_music,
                            size: 48,
                            color: Color(0xFF424242),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your queue is empty',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Long-press a search result to add songs.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    )
                  : StreamBuilder<int?>(
                      stream: handler.player.currentIndexStream,
                      builder: (context, snapshot) {
                        final currentIndex = snapshot.data ?? -1;
                        return ReorderableListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: queue.length,
                          onReorder: (oldIndex, newIndex) {
                            ref
                                .read(queueProvider.notifier)
                                .move(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final track = queue[index];
                            final isPlaying = index == currentIndex;

                            return Card(
                              key: ValueKey('queue_$index'),
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 32,
                                  child: Center(
                                    child: isPlaying
                                        ? Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF1DB954),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  track.songName ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        track.singers ?? 'Unknown artist',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (track.duration != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        track.duration!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Remove button
                                    Semantics(
                                      label: 'Remove from queue',
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 48,
                                          minHeight: 48,
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(queueProvider.notifier)
                                              .removeAt(index);
                                        },
                                      ),
                                    ),
                                    // Drag handle
                                    Semantics(
                                      label: 'Drag to reorder',
                                      child: ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(
                                          Icons.drag_handle,
                                          color: Color(0xFF424242),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
