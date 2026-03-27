import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/downloads/downloads_screen.dart';
import 'features/library/library_screen.dart';
import 'features/library/playlist_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/app_scaffold.dart';

/// Root application widget. Configures Material 3 dark theme and go_router.
class MusicDlApp extends ConsumerWidget {
  const MusicDlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MusicDL',
      debugShowCheckedModeBanner: false,
      theme: _darkTheme(),
      routerConfig: _router,
    );
  }
}

/// Dark theme per UI-SPEC.md color contract.
ThemeData _darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF1E1E1E),
      primary: Color(0xFF1DB954),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      indicatorColor: Color(0xFF1DB954),
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: Color(0xFF9E9E9E)),
      ),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: Color(0xFF9E9E9E)),
      ),
    ),
  );
}

/// go_router configuration with StatefulShellRoute for 4-tab bottom nav.
/// StatefulShellRoute.indexedStack preserves scroll and state per branch
/// when switching tabs.
final GoRouter _router = GoRouter(
  initialLocation: '/search',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'playlist/:id',
                  builder: (context, state) {
                    final id =
                        int.parse(state.pathParameters['id']!);
                    return PlaylistDetailScreen(playlistId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/downloads',
              builder: (context, state) => const DownloadsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
