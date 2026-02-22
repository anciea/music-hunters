import 'package:flutter/material.dart';

/// Per-source brand colors for the source badge chip.
///
/// Keys are lowercase source names as returned by the backend.
/// Fallback: Color(0xFF424242) neutral dark gray.
const Map<String, Color> sourceBadgeColors = {
  'netease': Color(0xFFCC0000),
  'qq': Color(0xFF1296DB),
  'spotify': Color(0xFF1AA34A),
  'youtube': Color(0xFFCC0000),
  'ytmusic': Color(0xFFCC0000),
  'tidal': Color(0xFF000000),
  'qobuz': Color(0xFF1C3A6B),
  'deezer': Color(0xFFA238FF),
  'kugou': Color(0xFF2979FF),
  'kuwo': Color(0xFFFF6E00),
  'migu': Color(0xFFE31837),
  'joox': Color(0xFF00C24B),
};

/// Returns the brand color for a given [source] string.
///
/// Falls back to neutral dark gray for unknown sources.
Color badgeColorFor(String source) =>
    sourceBadgeColors[source.toLowerCase()] ?? const Color(0xFF424242);

/// A compact colored chip that displays the music source platform name.
///
/// Height: 24dp, horizontal padding: 8dp, border-radius: 12dp.
/// Tidal (black background) gets a 1dp white border for contrast.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final bgColor = badgeColorFor(source);
    final isTidal = source.toLowerCase() == 'tidal';

    return Tooltip(
      message: source,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isTidal
              ? Border.all(color: Colors.white, width: 1)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          source,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
