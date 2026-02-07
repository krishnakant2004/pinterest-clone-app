import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pin/data/repositories/pin_repository_impl.dart';
import '../../../pin/domain/entities/pin.dart';

// State class for board ideas (Pexels search by board name)
class BoardIdeasState {
  final Map<String, List<Pin>> ideasByBoardId;
  final Set<String> loadingBoardIds;
  final Map<String, String> errorsByBoardId;

  const BoardIdeasState({
    this.ideasByBoardId = const {},
    this.loadingBoardIds = const {},
    this.errorsByBoardId = const {},
  });

  BoardIdeasState copyWith({
    Map<String, List<Pin>>? ideasByBoardId,
    Set<String>? loadingBoardIds,
    Map<String, String>? errorsByBoardId,
  }) {
    return BoardIdeasState(
      ideasByBoardId: ideasByBoardId ?? this.ideasByBoardId,
      loadingBoardIds: loadingBoardIds ?? this.loadingBoardIds,
      errorsByBoardId: errorsByBoardId ?? this.errorsByBoardId,
    );
  }

  List<Pin> getIdeasForBoard(String boardId) {
    return ideasByBoardId[boardId] ?? [];
  }

  bool isLoadingBoard(String boardId) {
    return loadingBoardIds.contains(boardId);
  }

  String? getErrorForBoard(String boardId) {
    return errorsByBoardId[boardId];
  }
}

// Notifier for board ideas (fetches from Pexels using board name)
class BoardIdeasNotifier extends StateNotifier<BoardIdeasState> {
  final Ref _ref;

  BoardIdeasNotifier(this._ref) : super(const BoardIdeasState());

  Future<void> loadIdeasForBoard(String boardId, String boardName) async {
    // Skip if already loading or already loaded
    if (state.loadingBoardIds.contains(boardId) ||
        state.ideasByBoardId.containsKey(boardId)) {
      return;
    }

    // Mark as loading
    state = state.copyWith(
      loadingBoardIds: {...state.loadingBoardIds, boardId},
    );

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(
      query: boardName,
      page: 1,
      perPage: 20,
    );

    result.fold(
      (failure) {
        final newLoadingIds = {...state.loadingBoardIds}..remove(boardId);
        state = state.copyWith(
          loadingBoardIds: newLoadingIds,
          errorsByBoardId: {...state.errorsByBoardId, boardId: failure.message},
        );
      },
      (pins) {
        final newLoadingIds = {...state.loadingBoardIds}..remove(boardId);
        state = state.copyWith(
          ideasByBoardId: {...state.ideasByBoardId, boardId: pins},
          loadingBoardIds: newLoadingIds,
        );
      },
    );
  }

  void clearIdeasForBoard(String boardId) {
    final newIdeas = {...state.ideasByBoardId}..remove(boardId);
    final newErrors = {...state.errorsByBoardId}..remove(boardId);
    state = state.copyWith(
      ideasByBoardId: newIdeas,
      errorsByBoardId: newErrors,
    );
  }

  void clearAll() {
    state = const BoardIdeasState();
  }
}

// Provider for board ideas
final boardIdeasProvider =
    StateNotifierProvider<BoardIdeasNotifier, BoardIdeasState>(
      (ref) => BoardIdeasNotifier(ref),
    );

// State class for home feed
class HomeFeedState {
  final List<Pin> pins;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasReachedEnd;

  const HomeFeedState({
    this.pins = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasReachedEnd = false,
  });

  HomeFeedState copyWith({
    List<Pin>? pins,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasReachedEnd,
  }) {
    return HomeFeedState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

// Notifier for home feed
class HomeFeedNotifier extends StateNotifier<HomeFeedState> {
  final Ref _ref;

  HomeFeedNotifier(this._ref) : super(const HomeFeedState()) {
    loadPins();
  }

  Future<void> loadPins() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.getCuratedPins(page: 1, perPage: 20);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pins) {
        state = state.copyWith(
          pins: pins,
          isLoading: false,
          currentPage: 1,
          hasReachedEnd: pins.isEmpty,
        );
      },
    );
  }

  Future<void> loadMorePins() async {
    if (state.isLoadingMore || state.hasReachedEnd) return;

    state = state.copyWith(isLoadingMore: true);

    final repository = _ref.read(pinRepositoryProvider);
    final nextPage = state.currentPage + 1;
    final result = await repository.getCuratedPins(page: nextPage, perPage: 20);

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingMore: false);
      },
      (pins) {
        state = state.copyWith(
          pins: [...state.pins, ...pins],
          isLoadingMore: false,
          currentPage: nextPage,
          hasReachedEnd: pins.isEmpty,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(currentPage: 1, hasReachedEnd: false);
    await loadPins();
  }
}

// Provider
final homeFeedProvider = StateNotifierProvider<HomeFeedNotifier, HomeFeedState>(
  (ref) {
    return HomeFeedNotifier(ref);
  },
);

// Selected pin provider for detail view
final selectedPinProvider = StateProvider<Pin?>((ref) => null);

// Related pins state for pin detail screen
class RelatedPinsState {
  final List<Pin> pins;
  final bool isLoading;
  final String? error;
  final String? currentPinId;

  const RelatedPinsState({
    this.pins = const [],
    this.isLoading = false,
    this.error,
    this.currentPinId,
  });

  RelatedPinsState copyWith({
    List<Pin>? pins,
    bool? isLoading,
    String? error,
    String? currentPinId,
  }) {
    return RelatedPinsState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPinId: currentPinId ?? this.currentPinId,
    );
  }
}

// Notifier for related pins (searches Pexels using pin title/photographer)
class RelatedPinsNotifier extends StateNotifier<RelatedPinsState> {
  final Ref _ref;

  RelatedPinsNotifier(this._ref) : super(const RelatedPinsState());

  Future<void> loadRelatedPins(Pin pin) async {
    // Skip if already loaded for this pin
    if (state.currentPinId == pin.id && state.pins.isNotEmpty) return;
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null, currentPinId: pin.id);

    // Use photographer name or title as search query
    final query = pin.photographer ?? pin.title ?? 'nature';

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(
      query: query,
      page: 1,
      perPage: 20,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pins) {
        // Filter out the current pin from results
        final filteredPins = pins.where((p) => p.id != pin.id).toList();
        state = state.copyWith(pins: filteredPins, isLoading: false);
      },
    );
  }

  void clear() {
    state = const RelatedPinsState();
  }
}

// Provider for related pins
final relatedPinsProvider =
    StateNotifierProvider<RelatedPinsNotifier, RelatedPinsState>(
      (ref) => RelatedPinsNotifier(ref),
    );

// Provider to track which board tabs have been visited (persists across navigation)
class VisitedBoardTabsNotifier extends StateNotifier<Set<int>> {
  VisitedBoardTabsNotifier() : super({0}); // "For you" is always visited

  void markVisited(int tabIndex) {
    if (!state.contains(tabIndex)) {
      state = {...state, tabIndex};
    }
  }

  bool isVisited(int tabIndex) => state.contains(tabIndex);

  void reset() {
    state = {0};
  }
}

final visitedBoardTabsProvider =
    StateNotifierProvider<VisitedBoardTabsNotifier, Set<int>>(
      (ref) => VisitedBoardTabsNotifier(),
    );
