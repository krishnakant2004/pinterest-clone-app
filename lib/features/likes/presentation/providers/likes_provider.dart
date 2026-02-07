import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_provider.dart';
import '../../data/repositories/like_repository_impl.dart';
import '../../domain/repositories/like_repository.dart';

/// State for likes
class LikesState {
  final Set<String> likedPinIds;
  final bool isLoading;
  final String? error;

  const LikesState({
    this.likedPinIds = const {},
    this.isLoading = false,
    this.error,
  });

  LikesState copyWith({
    Set<String>? likedPinIds,
    bool? isLoading,
    String? error,
  }) {
    return LikesState(
      likedPinIds: likedPinIds ?? this.likedPinIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing likes state
class LikesNotifier extends StateNotifier<LikesState> {
  final String? userId;
  final LikeRepository _repository;

  LikesNotifier(this.userId, this._repository) : super(const LikesState()) {
    if (userId != null) {
      loadLikes();
    }
  }

  /// Load all likes for the user
  Future<void> loadLikes() async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final likedPinIds = _repository.getUserLikedPinIds(userId!);
      state = state.copyWith(
        likedPinIds: likedPinIds.toSet(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Like a pin
  Future<bool> likePin(String pinId) async {
    if (userId == null) return false;

    // Optimistic update
    state = state.copyWith(likedPinIds: {...state.likedPinIds, pinId});

    final result = await _repository.likePin(userId: userId!, pinId: pinId);

    return result.fold((failure) {
      // Revert on failure
      final updatedLikes = Set<String>.from(state.likedPinIds)..remove(pinId);
      state = state.copyWith(likedPinIds: updatedLikes, error: failure.message);
      return false;
    }, (success) => success);
  }

  /// Unlike a pin
  Future<bool> unlikePin(String pinId) async {
    if (userId == null) return false;

    // Optimistic update
    final updatedLikes = Set<String>.from(state.likedPinIds)..remove(pinId);
    state = state.copyWith(likedPinIds: updatedLikes);

    final result = await _repository.unlikePin(userId: userId!, pinId: pinId);

    return result.fold((failure) {
      // Revert on failure
      state = state.copyWith(
        likedPinIds: {...state.likedPinIds, pinId},
        error: failure.message,
      );
      return false;
    }, (success) => success);
  }

  /// Toggle like status
  Future<bool> toggleLike(String pinId) async {
    if (isPinLiked(pinId)) {
      return unlikePin(pinId);
    } else {
      return likePin(pinId);
    }
  }

  /// Check if a pin is liked
  bool isPinLiked(String pinId) {
    return state.likedPinIds.contains(pinId);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for likes
final likesProvider = StateNotifierProvider<LikesNotifier, LikesState>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final repository = ref.watch(likeRepositoryProvider);
  return LikesNotifier(userId, repository);
});

/// Provider to check if a specific pin is liked
final isPinLikedProvider = Provider.family<bool, String>((ref, pinId) {
  final likesState = ref.watch(likesProvider);
  return likesState.likedPinIds.contains(pinId);
});
