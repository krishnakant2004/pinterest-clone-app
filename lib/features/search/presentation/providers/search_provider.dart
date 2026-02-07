import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../pin/data/repositories/pin_repository_impl.dart';
import '../../../pin/domain/entities/pin.dart';

class SearchState {
  final String query;
  final List<Pin> results;
  final bool isLoading;
  final String? error;
  final List<String> searchHistory;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.searchHistory = const [],
  });

  SearchState copyWith({
    String? query,
    List<Pin>? results,
    bool? isLoading,
    String? error,
    List<String>? searchHistory,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState());

  Future<void> search(String query , {int perPage = 30}) async {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: []);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(query: query, perPage: perPage);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pins) {
        state = state.copyWith(results: pins, isLoading: false);
        _addToHistory(query);
      },
    );
  }

  Future<List<Pin>> searchPins(String query , {int perPage = 30}) async {
    if (query.isEmpty) {
      return [];
    }

    final repository = _ref.read(pinRepositoryProvider);
    final result = await repository.searchPins(query: query, perPage: perPage);

    return result.fold(
      (failure) => [],
      (pins) {
        return pins;
      },
    );    
  }

  void clearSearch() {
    state = state.copyWith(query: '', results: []);
  }

  void _addToHistory(String query) {
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) {
      history.removeLast();
    }
    state = state.copyWith(searchHistory: history);
  }

  void removeFromHistory(String query) {
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    state = state.copyWith(searchHistory: history);
  }

  void clearHistory() {
    state = state.copyWith(searchHistory: []);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref);
});

