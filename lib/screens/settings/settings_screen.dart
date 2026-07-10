import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/providers/library_provider.dart';
import 'package:goodnight/providers/player_provider.dart';

/// Settings screen — manage preferences and view app info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Settings'),
            pinned: true,
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
          ),

          // App header card
          SliverToBoxAdapter(
            child: _AppHeaderCard(),
          ),

          // Section: Playback
          _SliverSection(
            title: 'Playback',
            children: [
              _SettingsTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF7BA8C9),
                title: 'Clear Recently Played',
                subtitle: 'Remove your listening history',
                onTap: () => _clearRecent(context),
              ),
            ],
          ),

          // Section: Library
          _SliverSection(
            title: 'Library',
            children: [
              _SettingsTile(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFC998B8),
                title: 'Clear Favorites',
                subtitle: 'Remove all saved talks',
                onTap: () => _clearFavorites(context),
              ),
            ],
          ),

          // Section: About
          _SliverSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Version',
                subtitle: _appVersion,
                onTap: null,
                trailing: Text(
                  _appVersion,
                  style: AppTextStyles.bodySmall,
                ),
              ),
              _SettingsTile(
                icon: Icons.library_books_outlined,
                iconColor: const Color(0xFF7DBEA6),
                title: 'Content Source',
                subtitle: 'dhammadownload.com',
                onTap: null,
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Future<void> _clearRecent(BuildContext context) async {
    final confirmed = await _confirmDialog(
      context,
      title: 'Clear History?',
      message: 'Your recently played list will be cleared.',
    );
    if (confirmed == true && context.mounted) {
      await context.read<LibraryProvider>().clearRecentlyPlayed();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recently played cleared')),
        );
      }
    }
  }

  Future<void> _clearFavorites(BuildContext context) async {
    final confirmed = await _confirmDialog(
      context,
      title: 'Clear Favorites?',
      message: 'All your saved talks will be removed.',
    );
    if (confirmed == true && context.mounted) {
      await context.read<LibraryProvider>().clearFavorites();
      // Also refresh the player favorite indicator
      // ignore: use_build_context_synchronously
      context.read<PlayerProvider>(); // triggers listeners
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favorites cleared')),
        );
      }
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardElevated,
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Clear',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App header ─────────────────────────────────────────────────────────────

class _AppHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.card,
              AppColors.primary.withOpacity(0.12),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: const Icon(Icons.nightlight_round,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Night', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Buddhist Dhamma Talks',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section ────────────────────────────────────────────────────────────────

class _SliverSection extends StatelessWidget {
  const _SliverSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings tile ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: iconColor.withOpacity(0.18),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }
}
