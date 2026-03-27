import 'package:flutter/material.dart';

/// Search screen — placeholder for Plan 02.
/// The full search UI (search bar, results list, shimmer skeleton) will be
/// implemented in Phase 02 Plan 02.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search screen')),
    );
  }
}
