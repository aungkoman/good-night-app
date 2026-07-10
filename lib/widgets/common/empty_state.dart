import 'package:flutter/material.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';

/// A beautiful, calming empty-state widget used across the app.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
