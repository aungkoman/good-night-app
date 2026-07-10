import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/constants/app_constants.dart';
import 'package:goodnight/core/extensions/string_extensions.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/widgets/now_playing_artwork.dart';
import 'package:goodnight/widgets/playback_controls.dart';
import 'package:goodnight/widgets/sleep_timer_sheet.dart';

/// The primary screen — an immersive Now Playing experience.
///
/// Users should be listening to Dhamma within seconds of opening the app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final track = player.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Subtle background gradient
          _BackgroundGradient(
            collectionIndex: track?.collectionIndex ?? 0,
          ),
          SafeArea(
            child: Column(
              children: [
                _AppBar(player: player),
                Expanded(
                  child: track == null
                      ? const _LoadingView()
                      : _PlayerContent(player: player),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────────

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient({required this.collectionIndex});

  final int collectionIndex;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(collectionIndex);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.2,
          colors: [
            colors[0].withOpacity(0.12),
            AppColors.background,
          ],
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text('Good Night', style: AppTextStyles.headlineLarge),
          const Spacer(),
          // Sleep timer button
          _SleepTimerButton(player: player),
        ],
      ),
    );
  }
}

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    final isActive = player.hasSleepTimer;
    final remaining = player.sleepRemainingSec;

    return GestureDetector(
      onTap: () => SleepTimerSheet.show(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: AppColors.primary.withOpacity(0.5))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime_outlined,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                _formatRemaining(remaining),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRemaining(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text('Loading Dhamma…', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _PlayerContent extends StatelessWidget {
  const _PlayerContent({required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    final track = player.currentTrack!;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.04),
          // Artwork
          NowPlayingArtwork(
            collectionIndex: track.collectionIndex,
            isPlaying: player.status == PlayerStatus.playing,
          ),
          SizedBox(height: screenHeight * 0.04),
          // Track info
          _TrackInfo(track: track),
          const SizedBox(height: 28),
          // Seek bar
          _SeekBar(player: player),
          const SizedBox(height: 28),
          // Playback controls
          PlaybackControls(player: player),
          const SizedBox(height: 24),
          // Bottom actions: speed + favorite
          _BottomActions(player: player),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Track info ────────────────────────────────────────────────────────────────

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({required this.track});

  final DhammaTrack track;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            track.label,
            key: ValueKey(track.id),
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          track.sayadawName,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Seek bar ──────────────────────────────────────────────────────────────────

class _SeekBar extends StatefulWidget {
  const _SeekBar({required this.player});

  final PlayerProvider player;

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final pos = widget.player.position;
    final dur = widget.player.duration;
    final ratio = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Slider(
          value: _dragValue ?? ratio,
          onChangeStart: (_) => setState(() => _dragValue = ratio),
          onChanged: (v) => setState(() => _dragValue = v),
          onChangeEnd: (v) {
            widget.player.seek(v);
            setState(() => _dragValue = null);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(pos.formatted, style: AppTextStyles.caption),
              Text(dur.formatted, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bottom actions ────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.player});

  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Speed selector
        _SpeedSelector(
          currentSpeed: player.speed,
          onSelected: player.setSpeed,
        ),
        // Favorite
        _FavoriteButton(
          isFavorite: player.isFavorite,
          onTap: player.toggleFavorite,
        ),
      ],
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({
    required this.currentSpeed,
    required this.onSelected,
  });

  final double currentSpeed;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      onSelected: onSelected,
      color: AppColors.cardElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => AppConstants.speeds
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  if (s == currentSpeed)
                    const Icon(Icons.check_rounded,
                        size: 16, color: AppColors.primary)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$s×',
                    style: s == currentSpeed
                        ? AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary)
                        : AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.speed_rounded,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              '$currentSpeed×',
              style: AppTextStyles.labelLarge
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFavorite
              ? AppColors.primary.withOpacity(0.18)
              : AppColors.card,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_outline,
            key: ValueKey(isFavorite),
            color: isFavorite ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
