import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Trending and recent searches suggestions view
class SearchSuggestions extends StatelessWidget {
  final List<String> trendingSearches;
  final List<String> recentSearches;
  final void Function(String query) onSearchTap;

  const SearchSuggestions({
    super.key,
    required this.trendingSearches,
    required this.onSearchTap,
    this.recentSearches = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const Text(
          'Trending searches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TrendingSearchChips(searches: trendingSearches, onTap: onSearchTap),
        const SizedBox(height: 24),
        const Text(
          'Recent searches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (recentSearches.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No recent searches',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          )
        else
          ...recentSearches.map(
            (search) => RecentSearchTile(
              query: search,
              onTap: () => onSearchTap(search),
            ),
          ),
      ],
    );
  }
}

/// Wrap of trending search chips
class TrendingSearchChips extends StatelessWidget {
  final List<String> searches;
  final void Function(String query) onTap;

  const TrendingSearchChips({
    super.key,
    required this.searches,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          searches
              .map(
                (search) => ActionChip(
                  label: Text(search),
                  onPressed: () => onTap(search),
                  backgroundColor: AppColors.greyBackground,
                ),
              )
              .toList(),
    );
  }
}

/// Recent search tile with history icon
class RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const RecentSearchTile({
    super.key,
    required this.query,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, color: AppColors.grey),
      title: Text(query),
      trailing:
          onRemove != null
              ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.grey),
                onPressed: onRemove,
              )
              : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
