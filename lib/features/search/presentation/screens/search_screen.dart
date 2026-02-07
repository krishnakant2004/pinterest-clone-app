import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone/features/pin/domain/entities/pin.dart';
import 'package:pinterest_clone/features/search/presentation/widgets/idea_for_you_widget.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/search_provider.dart';
import '../widgets/widgets.dart';
// ADD THIS IMPORT

// Fixed typos
const List<String> ideaForYou = [
  'Beautiful Views Video', // Fixed: Buetiful → Beautiful
  'Graphic Design fun',
  'Pfp aesthetic',
  'Cartoon profile pics', // Fixed: cartoon → Cartoon
  'Singles inferno season 5',
  'Character design',
  'Instagram Highlights covers',
  'Tiktok sticker',
  'Roblox avatars', // Fixed: Reblox → Roblox
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isSearchFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Rebuild to show/hide clear button
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        ref.read(searchProvider.notifier).search(query);
      }
    });
  }

  void _performSearch(String query) {
    _searchController.text = query;
    _focusNode.unfocus();
    ref.read(searchProvider.notifier).search(query);
  }

  Future<List<Pin>> generateCardsForSection(int index) async {
    try {
      // Get pins for Card Section with error handling
      final pins = await ref
          .read(searchProvider.notifier)
          .searchPins(ideaForYou[index], perPage: 5);
      
      // Ensure we have at least 5 pins, if not, fill with dummy pins or return what we have
      if (pins.length < 5) {
        print('Warning: Only ${pins.length} pins found for ${ideaForYou[index]}');
      }
      
      return pins;
    } catch (e) {
      print('Error fetching pins for ${ideaForYou[index]}: $e');
      return []; // Return empty list on error
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    ref.read(searchProvider.notifier).clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            AppSearchBar(
              controller: _searchController,
              focusNode: _focusNode,
              showBackButton: _isSearchFocused || searchState.query.isNotEmpty,
              onChanged: _onSearchChanged,
              onSubmitted: _performSearch,
              onClear: _clearSearch,
            ),
            // Content
            Expanded(child: _buildContent(searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state) {
    // Show suggestions when search is focused and empty
    if (_isSearchFocused && state.query.isEmpty) {
      return SearchSuggestions(
        trendingSearches: SearchCategories.trendingSearches,
        onSearchTap: _performSearch,
      );
    }

    // Show loading shimmer
    if (state.isLoading && state.results.isEmpty) {
      return const ShimmerGrid();
    }

    // Show search results
    if (state.results.isNotEmpty) {
      return SearchResultsGrid(
        results: state.results,
        query: state.query,
        onRefresh: () => ref.read(searchProvider.notifier).search(state.query),
        onPinTap: (pin) {
          context.push('${RouteNames.pinDetail}/${pin.id}', extra: pin);
        },
      );
    }

    // Default: Show Pinterest Card Sections
    return SingleChildScrollView(
      child: Column(
        children: [
          //TODO: Banner Carousel Section
          const SizedBox(height: 8),
          
          // Generate a section for each idea
          ...List.generate(ideaForYou.length, (index) {
            return Column(
              children: [
                PinterestCardSection(
                  sectionTitle: ideaForYou[index],
                  pins: generateCardsForSection(index),
                  onSearchTap: () {
                    _performSearch(ideaForYou[index]);
                  },
                ),
                
                const SizedBox(height: 24),
              ],
            );
          }),
          
          // Bottom padding
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}