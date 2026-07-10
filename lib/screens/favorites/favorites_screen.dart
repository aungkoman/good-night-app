import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/providers/library_provider.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/widgets/common/empty_state.dart';
import 'package:goodnight/widgets/track_list_tile.dart';

/// Favorites screen — shows all locally persisted favorited tracks.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final favorites = library.favorites;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Favorites'),
            pinned: true,
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            actions: [
              if (favorites.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context, library),
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),

          if (favorites.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.favorite_outline_rounded,
                title: 'No Favorites Yet',
                subtitle:
                    'Tap the ♥ on the Now Playing screen to save talks you love.',
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              sliver: SliverToBoxAdapter(
                child: Text(
                  '${favorites.length} saved',
                  style: AppTextStyles.caption,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final track = favorites[i];
                  return Column(
                    children: [
                      TrackListTileConnected(
                        track: track,
                        index: i,
                        player: player,
                        onTap: () {
                          player.playTrack(track);
                        },
                      ),
                      const Divider(height: 1, indent: 64),
                    ],
                  );
                },
                childCount: favorites.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, LibraryProvider library) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardElevated,
        title: Text('Clear Favorites?', style: AppTextStyles.titleLarge),
        content: Text(
          'All favorited tracks will be removed.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // ignore: use_build_context_synchronously
      await context.read<LibraryProvider>().clearFavorites();
    }
  }
}
