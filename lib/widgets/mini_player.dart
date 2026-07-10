import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/providers/player_provider.dart';

/// Compact player bar shown above the bottom navigation when not on Home.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final colors = AppColors.gradientForIndex(track.collectionIndex);
    final progress = player.duration.inMilliseconds > 0
        ? (player.position.inMilliseconds / player.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final isPlaying = player.status == PlayerStatus.playing;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.miniPlayerBg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thin progress bar at top
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
              minHeight: 2,
            ),
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  // Gradient avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                    ),
                    child: const Icon(Icons.spa_rounded,
                        size: 18, color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          track.label,
                          style: AppTextStyles.titleMedium,
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
                  // Play / pause
                  IconButton(
                    onPressed: player.togglePlayPause,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    splashRadius: 20,
                  ),
                  // Next
                  IconButton(
                    onPressed: player.playNext,
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                    splashRadius: 20,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
