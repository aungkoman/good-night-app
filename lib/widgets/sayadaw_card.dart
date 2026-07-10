import 'package:flutter/material.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/models/sayadaw_collection.dart';

/// Card representing a Sayadaw collection in the Library screen.
class SayadawCard extends StatelessWidget {
  const SayadawCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  final SayadawCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradientForIndex(collection.index);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Color accent strip
              Container(
                width: 5,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Avatar circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[0].withOpacity(0.5),
                      colors[1].withOpacity(0.5),
                    ],
                  ),
                ),
                child: Icon(Icons.person_rounded,
                    size: 22, color: colors[0]),
              ),
              const SizedBox(width: 14),
              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collection.displayName,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${collection.totalMp3s} talks',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
