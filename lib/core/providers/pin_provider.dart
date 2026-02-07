import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/pin/data/repositories/pin_repository_impl.dart';
import '../../features/pin/domain/entities/pin.dart';

// ============================================================================
// PIN STATE - Only Feed/Search/Related functionality
// ============================================================================

/// State for pin feed, search, and related pins
class PinState {
  // Feed pins (from Pexels API)
  final List<Pin> feedPins;
  final bool isFeedLoading;
  final bool isFeedLoadingMore;
  final int feedCurrentPage;
  final bool feedHasReachedEnd;

  // Selected pin for detail view
  final Pin? selectedPin;

  // Related pins for detail view
  final List<Pin> relatedPins;
  final bool isRelatedPinsLoading;
  final String? relatedPinsForPinId;

  // Search results
  final List<Pin> searchResults;
  final bool isSearching;
  final String searchQuery;

  // General error
  final String? error;

  const PinState({
    this.feedPins = const [],
    this.isFeedLoading = false,
    this.isFeedLoadingMore = false,
    this.feedCurrentPage = 1,
    this.feedHasReachedEnd = false,
    this.selectedPin,
    this.relatedPins = const [],
    this.isRelatedPinsLoading = false,
    this.relatedPinsForPinId,
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery = '',
    this.error,
  });

  PinState copyWith({
    List<Pin>? feedPins,
    bool? isFeedLoading,
    bool? isFeedLoadingMore,
    int? feedCurrentPage,
    bool? feedHasReachedEnd,
    Pin? selectedPin,
    bool clearSelectedPin = false,
    List<Pin>? relatedPins,
    bool? isRelatedPinsLoading,
    String? relatedPinsForPinId,
    List<Pin>? searchResults,
    bool? isSearching,
    String? searchQuery,
    String? error,
    bool clearError = false,
  }) {
    return PinState(
      feedPins: feedPins ?? this.feedPins,
      isFeedLoading: isFeedLoading ?? this.isFeedLoading,
      isFeedLoadingMore: isFeedLoadingMore ?? this.isFeedLoadingMore,
      feedCurrentPage: feedCurrentPage ?? this.feedCurrentPage,
      feedHasReachedEnd: feedHasReachedEnd ?? this.feedHasReachedEnd,
      selectedPin: clearSelectedPin ? null : (selectedPin ?? this.selectedPin),
      relatedPins: relatedPins ?? this.relatedPins,
      isRelatedPinsLoading: isRelatedPinsLoading ?? this.isRelatedPinsLoading,
      relatedPinsForPinId: relatedPinsForPinId ?? this.relatedPinsForPinId,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ============================================================================
// PIN NOTIFIER - Only Feed/Search/Related operations
// ============================================================================

/// Notifier that manages feed, search, and related pins
class PinNotifier extends StateNotifier<PinState> {
  final Ref _ref;

  PinNotifier(this._ref) : super(const PinState()) {
    _initialize();
  }

  void _initialize() {
    loadFeedPins();
  }

  // ==========================================================================
  // FEED PINS (Pexels API)
  // ==========================================================================

  /// Load curated pins for the home feed
  Future<void> loadFeedPins() async {
    if (state.isFeedLoading) return;

    state = state.copyWith(isFeedLoading: true, clearError: true);

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.getCuratedPins(page: 1, perPage: 20);

    result.fold(
      (failure) {
        state = state.copyWith(isFeedLoading: false, error: failure.message);
      },
      (pins) {
        state = state.copyWith(
          feedPins: pins,
          isFeedLoading: false,
          feedCurrentPage: 1,
          feedHasReachedEnd: pins.isEmpty,
        );
      },
    );
  }

  /// Load more pins for infinite scroll
  Future<void> loadMoreFeedPins() async {
    if (state.isFeedLoadingMore || state.feedHasReachedEnd) return;

    state = state.copyWith(isFeedLoadingMore: true);

    final repository = _ref.read(pinRepositoryProvider);
    final nextPage = state.feedCurrentPage + 1;
    final result = await repository.getCuratedPins(page: nextPage, perPage: 20);

    result.fold(
      (failure) {
        state = state.copyWith(isFeedLoadingMore: false);
      },
      (pins) {
        state = state.copyWith(
          feedPins: [...state.feedPins, ...pins],
          isFeedLoadingMore: false,
          feedCurrentPage: nextPage,
          feedHasReachedEnd: pins.isEmpty,
        );
      },
    );
  }

  /// Refresh feed pins
  Future<void> refreshFeedPins() async {
    state = state.copyWith(feedCurrentPage: 1, feedHasReachedEnd: false);
    await loadFeedPins();
  }

  /// Get a pin by ID from Pexels API
  Future<Pin?> getPinById(String pinId) async {
    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.getPinById(pinId);

    return result.fold((failure) => null, (pin) => pin);
  }

  // ==========================================================================
  // SEARCH
  // ==========================================================================

  /// Search pins by query
  Future<void> searchPins(String query, {int page = 1}) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true, searchQuery: query);

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(
      query: query,
      page: page,
      perPage: 20,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isSearching: false, error: failure.message);
      },
      (pins) {
        state = state.copyWith(
          searchResults: page == 1 ? pins : [...state.searchResults, ...pins],
          isSearching: false,
        );
      },
    );
  }

  /// Clear search results
  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      isSearching: false,
    );
  }

  // ==========================================================================
  // MORE TO EXPLORE - Simple fetch methods
  // ==========================================================================

  /// Fetch pins by keyword (for Board context)
  Future<List<Pin>> fetchPinsByKeyword(String keyword) async {
    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(
      query: keyword,
      page: 1,
      perPage: 20,
    );
    return result.fold((failure) => <Pin>[], (pins) => pins);
  }

  /// Fetch random curated pins (for For You context)
  Future<List<Pin>> fetchRandomCuratedPins() async {
    final repository = _ref.read(pinRepositoryProvider);
    final randomPage = DateTime.now().millisecondsSinceEpoch % 10 + 1;
    final result = await repository.getCuratedPins(
      page: randomPage,
      perPage: 20,
    );
    return result.fold((failure) => <Pin>[], (pins) => pins);
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Main pin provider - handles feed, search, and related pins
final pinProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier(ref);
});

/// Provider for the currently selected pin
final selectedPinProvider = Provider<Pin?>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.selectedPin;
});

/// Provider for feed pins
final feedPinsProvider = Provider<List<Pin>>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.feedPins;
});

/// Provider for related pins
final relatedPinsProvider = Provider<List<Pin>>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.relatedPins;
});

/// Provider for search results
final searchResultsProvider = Provider<List<Pin>>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.searchResults;
});

/// Provider to check feed loading state
final isFeedLoadingProvider = Provider<bool>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.isFeedLoading;
});

/// Provider to check if feed is loading more
final isFeedLoadingMoreProvider = Provider<bool>((ref) {
  final pinState = ref.watch(pinProvider);
  return pinState.isFeedLoadingMore;
});
