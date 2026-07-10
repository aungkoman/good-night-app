import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/models/sayadaw_collection.dart';
import 'package:goodnight/providers/library_provider.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/widgets/sayadaw_card.dart';
import 'package:goodnight/widgets/track_list_tile.dart';

/// Library screen — Recently Played + All Sayadaw collections.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final player = context.watch<PlayerProvider>();
    final recent = library.recentlyPlayed;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            title: const Text('Library'),
            pinned: true,
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
          ),

          // Recently Played section
          if (recent.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Recently Played'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recent.length,
                  itemBuilder: (context, i) => _RecentTrackChip(
                    track: recent[i],
                    isPlaying: player.currentTrack?.id == recent[i].id &&
                        player.status == PlayerStatus.playing,
                    onTap: () => player.playTrack(recent[i]),
                  ),
                ),
              ),
            ),
          ],

          // All Teachers section
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'All Teachers'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => SayadawCard(
                collection: library.collections[i],
                onTap: () => _openCollection(context, library.collections[i]),
              ),
              childCount: library.collections.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _openCollection(BuildContext context, SayadawCollection collection) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<PlayerProvider>(),
          child: CollectionDetailScreen(collection: collection),
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title, style: AppTextStyles.headlineMedium),
    );
  }
}

// ── Recent track chip ──────────────────────────────────────────────────────

class _RecentTrackChip extends StatelessWidget {
  const _RecentTrackChip({
    required this.track,
    required this.isPlaying,
    required this.onTap,
  });

  final DhammaTrack track;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(track.collectionIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 10, bottom: 4, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: isPlaying
              ? Border.all(color: colors[0].withOpacity(0.6))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: isPlaying
                      ? const Icon(Icons.equalizer_rounded,
                          size: 14, color: Colors.white)
                      : const Icon(Icons.play_arrow_rounded,
                          size: 14, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              track.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              track.sayadawName,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collection detail screen ───────────────────────────────────────────────

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.collection});

  final SayadawCollection collection;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final colors = AppColors.gradientForIndex(collection.index);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Flexible header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors[0].withOpacity(0.3),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            collection.displayName,
                            style: AppTextStyles.headlineLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${collection.totalMp3s} Dhamma talks',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Track list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final track = collection.tracks[i];
                return Column(
                  children: [
                    TrackListTileConnected(
                      track: track,
                      index: i,
                      player: player,
                      onTap: () => player.playTrack(track),
                    ),
                    const Divider(height: 1, indent: 64),
                  ],
                );
              },
              childCount: collection.tracks.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
