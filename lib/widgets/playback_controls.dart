import 'package:flutter/material.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/providers/player_provider.dart';

/// Playback control row: ⏮15s · ◀ · ▶/⏸ · ▶ · 15s⏭
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key, required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    final isLoading = player.status == PlayerStatus.loading;
    final isPlaying = player.status == PlayerStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SeekButton(isForward: false, onPressed: player.skipBackward),
        _SkipButton(
          icon: Icons.skip_previous_rounded,
          onPressed: player.playPrevious,
          size: 28,
        ),
        _PlayPauseButton(
          isLoading: isLoading,
          isPlaying: isPlaying,
          onTap: player.togglePlayPause,
        ),
        _SkipButton(
          icon: Icons.skip_next_rounded,
          onPressed: player.playNext,
          size: 28,
        ),
        _SeekButton(isForward: true, onPressed: player.skipForward),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isLoading,
    required this.isPlaying,
    required this.onTap,
  });

  final bool isLoading;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.38),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 36,
                color: Colors.white,
              ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: AppColors.textSecondary),
      splashRadius: 24,
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({required this.isForward, required this.onPressed});

  final bool isForward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isForward ? Icons.forward_10_rounded : Icons.replay_10_rounded,
            size: 36,
            color: AppColors.textSecondary,
          ),
          Padding(
            padding: EdgeInsets.only(top: isForward ? 2.0 : 0.0),
            child: Text(
              '15',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
