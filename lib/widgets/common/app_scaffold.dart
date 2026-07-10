import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/screens/home/home_screen.dart';
import 'package:goodnight/screens/library/library_screen.dart';
import 'package:goodnight/screens/search/search_screen.dart';
import 'package:goodnight/screens/favorites/favorites_screen.dart';
import 'package:goodnight/screens/settings/settings_screen.dart';
import 'package:goodnight/widgets/mini_player.dart';

/// Root scaffold — hosts bottom navigation and the 5 main screens.
class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    LibraryScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void _goTo(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final hasTrack =
        context.select<PlayerProvider, bool>((p) => p.currentTrack != null);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player — visible on all tabs except Home
          if (hasTrack && _currentIndex != 0)
            MiniPlayer(onTap: () => _goTo(0)),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _goTo,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.nightlight_outlined),
                selectedIcon: Icon(Icons.nightlight),
                label: 'Now Playing',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
