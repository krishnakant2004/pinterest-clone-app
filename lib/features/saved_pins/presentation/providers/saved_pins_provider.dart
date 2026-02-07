import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_provider.dart';
import '../../../boards/presentation/providers/boards_provider.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../data/repositories/saved_pin_repository_impl.dart';
import '../../domain/entities/saved_pin.dart';
import '../../domain/repositories/saved_pin_repository.dart';

/// State for saved pins
class SavedPinsState {
  final List<SavedPin> pins;
  final Set<String> savedPinIds;
  final bool isLoading;
  final String? error;

  const SavedPinsState({
    this.pins = const [],
    this.savedPinIds = const {},
    this.isLoading = false,
    this.error,
  });

  SavedPinsState copyWith({
    List<SavedPin>? pins,
    Set<String>? savedPinIds,
    bool? isLoading,
    String? error,
  }) {
    return SavedPinsState(
      pins: pins ?? this.pins,
      savedPinIds: savedPinIds ?? this.savedPinIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing saved pins state
class SavedPinsNotifier extends StateNotifier<SavedPinsState> {
  final String? userId;
  final SavedPinRepository _repository;
  final Ref _ref;

  SavedPinsNotifier(this.userId, this._repository, this._ref)
    : super(const SavedPinsState()) {
    if (userId != null) {
      loadSavedPins();
    }
  }

  /// Load all saved pins for the user
  Future<void> loadSavedPins() async {
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getUserSavedPins(userId!);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (pins) {
        state = state.copyWith(
          pins: pins,
          savedPinIds: pins.map((p) => p.pinId).toSet(),
          isLoading: false,
        );
      },
    );
  }

  /// Save a pin to a board
  Future<bool> savePin(Pin pin, String boardId) async {
    if (userId == null) return false;

    // Optimistic update
    state = state.copyWith(savedPinIds: {...state.savedPinIds, pin.id});

    final result = await _repository.savePin(
      userId: userId!,
      pin: pin,
      boardId: boardId,
    );

    return result.fold(
      (failure) {
        // Revert on failure
        final updatedIds = Set<String>.from(state.savedPinIds)..remove(pin.id);
        state = state.copyWith(savedPinIds: updatedIds, error: failure.message);
        return false;
      },
      (savedPin) {
        state = state.copyWith(pins: [...state.pins, savedPin]);
        // Update board pin count
        _ref.read(boardsProvider.notifier).incrementPinCount(boardId);
        return true;
      },
    );
  }

  /// Unsave a pin
  Future<bool> unsavePin(String pinId, String boardId) async {
    if (userId == null) return false;

    // Optimistic update
    final updatedIds = Set<String>.from(state.savedPinIds)..remove(pinId);
    final updatedPins = state.pins.where((p) => p.pinId != pinId).toList();
    state = state.copyWith(savedPinIds: updatedIds, pins: updatedPins);

    final result = await _repository.unsavePin(
      userId: userId!,
      pinId: pinId,
      boardId: boardId,
    );

    return result.fold(
      (failure) {
        // Revert on failure - reload saved pins
        loadSavedPins();
        return false;
      },
      (success) {
        // Update board pin count
        _ref.read(boardsProvider.notifier).decrementPinCount(boardId);
        return success;
      },
    );
  }

  /// Get saved pins for a specific board
  Future<List<SavedPin>> getBoardPins(String boardId) async {
    final result = await _repository.getBoardPins(boardId);
    return result.fold((failure) => [], (pins) => pins);
  }

  /// Check if a pin is saved
  bool isPinSaved(String pinId) {
    return state.savedPinIds.contains(pinId);
  }

  /// Get the board ID where a pin is saved
  String? getPinBoardId(String pinId) {
    if (userId == null) return null;
    return _repository.getPinBoardId(userId!, pinId);
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for saved pins
final savedPinsProvider =
    StateNotifierProvider<SavedPinsNotifier, SavedPinsState>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      final repository = ref.watch(savedPinRepositoryProvider);
      return SavedPinsNotifier(userId, repository, ref);
    });

/// Provider to check if a specific pin is saved
final isPinSavedProvider = Provider.family<bool, String>((ref, pinId) {
  final savedPinsState = ref.watch(savedPinsProvider);
  return savedPinsState.savedPinIds.contains(pinId);
});

/// Provider to get saved pins for a specific board
final boardPinsProvider = FutureProvider.family<List<SavedPin>, String>((
  ref,
  boardId,
) async {
  final notifier = ref.watch(savedPinsProvider.notifier);
  return notifier.getBoardPins(boardId);
});
