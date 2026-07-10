import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/providers/player_provider.dart';

/// Bottom sheet for setting or cancelling the sleep timer.
class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PlayerProvider>(),
        child: const SleepTimerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Sleep Timer', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text(
              player.hasSleepTimer
                  ? 'Timer active — stops in ${_formatRemaining(player.sleepRemainingSec)}'
                  : 'Audio will pause automatically after the selected time.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            ..._buildOptions(context, player),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(BuildContext context, PlayerProvider player) {
    const options = [
      (0, 'Off'),
      (15, '15 minutes'),
      (30, '30 minutes'),
      (45, '45 minutes'),
      (60, '60 minutes'),
    ];

    return options.map(((int, String) option) {
      final (minutes, label) = option;
      final isSelected = player.sleepMinutes == minutes;

      return InkWell(
        onTap: () {
          player.setSleepTimer(minutes);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: isSelected
                    ? AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.primary)
                    : AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _formatRemaining(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
