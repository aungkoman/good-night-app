import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goodnight/core/theme/app_colors.dart';
import 'package:goodnight/core/theme/app_text_styles.dart';
import 'package:goodnight/models/dhamma_track.dart';
import 'package:goodnight/providers/player_provider.dart';
import 'package:goodnight/services/data_service.dart';
import 'package:goodnight/widgets/common/empty_state.dart';
import 'package:goodnight/widgets/track_list_tile.dart';

/// Search screen — instant local search across all 20,000+ tracks.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<DhammaTrack> _results = [];
  bool _hasQuery = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() => _hasQuery = value.trim().isNotEmpty);
    if (value.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final results = DataService.instance.search(value);
      if (mounted) setState(() => _results = results);
    });
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Search', style: AppTextStyles.headlineLarge),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                onClear: _clear,
                hasQuery: _hasQuery,
              ),
            ),

            const SizedBox(height: 12),

            // Results
            Expanded(
              child: _hasQuery
                  ? _ResultsList(
                      results: _results,
                      player: player,
                    )
                  : _EmptySearch(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search Dhamma talks, Sayadaw…',
          hintStyle: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.textDisabled),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 22),
          suffixIcon: hasQuery
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Results list ─────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.player,
  });

  final List<DhammaTrack> results;
  final PlayerProvider player;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results',
        subtitle: 'Try a different keyword or Sayadaw name.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            '${results.length} results',
            style: AppTextStyles.caption,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: results.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 64),
            itemBuilder: (context, i) => TrackListTileConnected(
              track: results[i],
              index: i,
              player: player,
              onTap: () => player.playTrack(results[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty / prompt state ──────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              'Search Dhamma Talks',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Search by title, Sayadaw name, or keywords in Myanmar or English.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
