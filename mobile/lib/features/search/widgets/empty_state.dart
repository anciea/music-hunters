import 'package:flutter/material.dart';

/// Centered empty state for the search results area.
///
/// Two variants:
///   [hasSearched] == false — first-launch state (no query submitted yet)
///   [hasSearched] == true  — no results returned for the submitted query
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.hasSearched = false});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    final icon = hasSearched ? Icons.search_off : Icons.music_note;
    final heading = hasSearched
        ? 'No music found for that search'
        : 'Search for music';
    final body = hasSearched
        ? 'Try a different search term or check your connection.'
        : 'Type a song, artist, or album above to find music from 21+ sources.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFF424242),
            ),
            const SizedBox(height: 16),
            Text(
              heading,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
