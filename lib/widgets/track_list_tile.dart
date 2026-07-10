import 'package:flutter/material.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/providers/player_provider.dart';

/// A single row in a track list — title, Sayadaw name, and playing indicator.
class TrackListTile extends StatelessWidget {
  const TrackListTile({
    super.key,
    required this.track,
    required this.index,
    required this.isCurrentlyPlaying,
    required this.onTap,
  });

  final DhammaTrack track;
  final int index;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(track.collectionIndex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Track number / playing indicator
            SizedBox(
              width: 36,
              child: isCurrentlyPlaying
                  ? Icon(Icons.equalizer_rounded,
                      size: 20, color: colors[0])
                  : Text(
                      '${index + 1}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 12),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.label,
                    style: isCurrentlyPlaying
                        ? AppTextStyles.titleMedium.copyWith(color: colors[0])
                        : AppTextStyles.titleMedium,
                    maxLines: 2,
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateless wrapper that reads [PlayerProvider] for the currently playing
/// track state — avoids rebuilding the whole list on every position update.
class TrackListTileConnected extends StatelessWidget {
  const TrackListTileConnected({
    super.key,
    required this.track,
    required this.index,
    required this.player,
    required this.onTap,
  });

  final DhammaTrack track;
  final int index;
  final PlayerProvider player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaying = player.currentTrack?.id == track.id &&
        player.status == PlayerStatus.playing;
    return TrackListTile(
      track: track,
      index: index,
      isCurrentlyPlaying: isPlaying,
      onTap: onTap,
    );
  }
}
