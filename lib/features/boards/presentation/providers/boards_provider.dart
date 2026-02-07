import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_provider.dart';
import '../../data/repositories/board_repository_impl.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';

/// State for boards
class BoardsState {
  final List<Board> boards;
  final bool isLoading;
  final String? error;

  const BoardsState({
    this.boards = const [],
    this.isLoading = false,
    this.error,
  });

  BoardsState copyWith({List<Board>? boards, bool? isLoading, String? error}) {
    return BoardsState(
      boards: boards ?? this.boards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing boards state
class BoardsNotifier extends StateNotifier<BoardsState> {
  final String? userId;
  final BoardRepository _repository;

  BoardsNotifier(this.userId, this._repository) : super(const BoardsState()) {
    if (userId != null) {
      loadBoards();
    }
  }

  /// Load all boards for the user
  Future<void> loadBoards() async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getUserBoards(userId!);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (boards) {
        state = state.copyWith(boards: boards, isLoading: false);
      },
    );
  }

  /// Create a new board
  Future<Board?> createBoard({
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    if (userId == null) return null;

    final result = await _repository.createBoard(
      userId: userId!,
      name: name,
      description: description,
      isPrivate: isPrivate,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (board) {
        state = state.copyWith(boards: [...state.boards, board]);
        return board;
      },
    );
  }

  /// Update an existing board
  Future<bool> updateBoard({
    required String boardId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isPrivate,
  }) async {
    final result = await _repository.updateBoard(
      boardId: boardId,
      name: name,
      description: description,
      coverImageUrl: coverImageUrl,
      isPrivate: isPrivate,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedBoard) {
        final updatedBoards =
            state.boards.map((b) {
              return b.id == boardId ? updatedBoard : b;
            }).toList();
        state = state.copyWith(boards: updatedBoards);
        return true;
      },
    );
  }

  /// Delete a board
  Future<bool> deleteBoard(String boardId) async {
    // Optimistic update
    final boardToDelete = state.boards.firstWhere(
      (b) => b.id == boardId,
      orElse: () => throw Exception('Board not found'),
    );
    state = state.copyWith(
      boards: state.boards.where((b) => b.id != boardId).toList(),
    );

    final result = await _repository.deleteBoard(boardId);

    return result.fold((failure) {
      // Revert on failure
      state = state.copyWith(
        boards: [...state.boards, boardToDelete],
        error: failure.message,
      );
      return false;
    }, (success) => success);
  }

  /// Increment pin count for a board
  void incrementPinCount(String boardId) {
    final updatedBoards =
        state.boards.map((b) {
          if (b.id == boardId) {
            return b.copyWith(pinCount: b.pinCount + 1);
          }
          return b;
        }).toList();
    state = state.copyWith(boards: updatedBoards);

    // Sync in background
    _repository.incrementPinCount(boardId);
  }

  /// Decrement pin count for a board
  void decrementPinCount(String boardId) {
    final updatedBoards =
        state.boards.map((b) {
          if (b.id == boardId && b.pinCount > 0) {
            return b.copyWith(pinCount: b.pinCount - 1);
          }
          return b;
        }).toList();
    state = state.copyWith(boards: updatedBoards);

    // Sync in background
    _repository.decrementPinCount(boardId);
  }

  /// Get a single board by ID
  Board? getBoard(String boardId) {
    try {
      return state.boards.firstWhere((b) => b.id == boardId);
    } catch (_) {
      return _repository.getBoard(boardId);
    }
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for boards
final boardsProvider = StateNotifierProvider<BoardsNotifier, BoardsState>((
  ref,
) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(boardRepositoryProvider);
  return BoardsNotifier(userId, repository);
});

/// Provider to get a specific board by ID
final boardProvider = Provider.family<Board?, String>((ref, boardId) {
  final boardsState = ref.watch(boardsProvider);
  try {
    return boardsState.boards.firstWhere((b) => b.id == boardId);
  } catch (_) {
    return null;
  }
});
