import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:goodnight/core/constants/app_constants.dart';
import 'package:goodnight/core/theme/app_colors.dart';

/// Animated artwork orb for the Now Playing screen.
///
/// Rotates and pulses gently when playing; pauses gracefully when paused.
/// Color gradient is derived from the collection index for visual variety.
class NowPlayingArtwork extends StatefulWidget {
  const NowPlayingArtwork({
    super.key,
    required this.collectionIndex,
    required this.isPlaying,
    this.size = AppConstants.artworkSize,
  });

  final int collectionIndex;
  final bool isPlaying;
  final double size;

  @override
  State<NowPlayingArtwork> createState() => _NowPlayingArtworkState();
}

class _NowPlayingArtworkState extends State<NowPlayingArtwork>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      duration: const Duration(seconds: 24),
      vsync: this,
    );
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.isPlaying) _startAnimations();
  }

  @override
  void didUpdateWidget(NowPlayingArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      widget.isPlaying ? _startAnimations() : _stopAnimations();
    }
    // Color change — rebuild immediately
    if (widget.collectionIndex != oldWidget.collectionIndex) {
      setState(() {});
    }
  }

  void _startAnimations() {
    _rotateCtrl.repeat();
    _pulseCtrl.repeat(reverse: true);
  }

  void _stopAnimations() {
    _rotateCtrl.stop();
    _pulseCtrl.stop();
    _pulseCtrl.animateTo(0, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(widget.collectionIndex);
    final size = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_rotateCtrl, _pulseAnim]),
      builder: (context, _) {
        return Transform.scale(
          scale: _pulseAnim.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: size + 32,
                height: size + 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.28),
                      blurRadius: 56,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
              // Main artwork circle
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating ring
                    Transform.rotate(
                      angle: _rotateCtrl.value * 2 * math.pi,
                      child: Container(
                        width: size * 0.80,
                        height: size * 0.80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Inner dark circle with icon
                    Container(
                      width: size * 0.50,
                      height: size * 0.50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.28),
                      ),
                      child: Icon(
                        Icons.spa_rounded,
                        size: size * 0.22,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
