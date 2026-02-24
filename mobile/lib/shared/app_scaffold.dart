import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'mini_player_bar.dart';

/// Shell scaffold with persistent bottom NavigationBar and mini player bar.
///
/// Receives the [StatefulNavigationShell] from go_router and renders the
/// current branch in the body while showing the 4-tab navigation bar.
///
/// The [MiniPlayerBar] is pinned above the [NavigationBar] and is visible
/// on all tabs whenever a track is playing.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mini player bar sits above the NavigationBar on all screens.
      // Column with Expanded body ensures the player bar is never scrolled off.
      body: Column(
        children: [
          Expanded(child: navigationShell),
          const MiniPlayerBar(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
