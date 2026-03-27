import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/player_provider.dart';

/// Seek bar widget with live drag timestamp preview.
///
/// Uses nested StreamBuilders on [durationStream] and [positionStream].
/// While the user is dragging, [_dragPosition] stores the preview position
/// and a formatted timestamp is shown above the slider thumb.
/// On drag end, [AudioHandler.seek] is called with the selected position.
///
/// No rxdart dependency — streams are from just_audio directly.
class SeekBar extends ConsumerStatefulWidget {
  const SeekBar({super.key});

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  /// Non-null while the user is actively dragging the slider thumb.
  double? _dragPosition;

  @override
  Widget build(BuildContext context) {
    final handler = ref.read(audioHandlerProvider);

    return StreamBuilder<Duration?>(
      stream: handler.player.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        final maxMs = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);

        return StreamBuilder<Duration>(
          stream: handler.player.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final currentMs = position.inMilliseconds.toDouble();

            // Use drag position for slider value while dragging, otherwise
            // use live position from stream.
            final sliderValue = (_dragPosition ?? currentMs).clamp(0.0, maxMs);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag timestamp label — only visible during drag
                if (_dragPosition != null)
                  Align(
                    // Map drag progress to horizontal alignment (-1.0 = left, 1.0 = right)
                    alignment: Alignment(
                      (sliderValue / maxMs * 2 - 1).clamp(-1.0, 1.0),
                      0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatDuration(
                          Duration(milliseconds: _dragPosition!.round()),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ),
                  ),

                // Seek slider
                Semantics(
                  slider: true,
                  value: _formatDuration(
                    Duration(milliseconds: sliderValue.round()),
                  ),
                  hint: 'Scrub to seek',
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF1DB954),
                      inactiveTrackColor: const Color(0xFF424242),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withAlpha(30),
                    ),
                    child: Slider(
                      value: sliderValue,
                      max: maxMs,
                      onChangeStart: (value) {
                        setState(() {
                          _dragPosition = value;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          _dragPosition = value;
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          _dragPosition = null;
                        });
                        ref.read(audioHandlerProvider).seek(
                              Duration(milliseconds: value.round()),
                            );
                      },
                    ),
                  ),
                ),

                // Position / duration row below the slider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Formats a [Duration] as mm:ss or h:mm:ss.
  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
