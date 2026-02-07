import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../pin/domain/entities/pin.dart';
import '../entities/saved_pin.dart';

/// Abstract repository interface for saved pins
abstract class SavedPinRepository {
  /// Save a pin to a board
  Future<Either<Failure, SavedPin>> savePin({
    required String userId,
    required Pin pin,
    required String boardId,
  });

  /// Unsave a pin
  Future<Either<Failure, bool>> unsavePin({
    required String userId,
    required String pinId,
    required String boardId,
  });

  /// Get saved pins for a board
  Future<Either<Failure, List<SavedPin>>> getBoardPins(String boardId);

  /// Get all saved pins for a user
  Future<Either<Failure, List<SavedPin>>> getUserSavedPins(String userId);

  /// Check if a pin is saved by user (sync - local only)
  bool isPinSaved({required String userId, required String pinId});

  /// Check if a pin is saved by user (async - with cloud fallback)
  Future<Either<Failure, bool>> isPinSavedAsync({
    required String userId,
    required String pinId,
  });

  /// Get the board ID where a pin is saved
  String? getPinBoardId(String userId, String pinId);

  /// Get all saved pin IDs for a user
  Set<String> getSavedPinIds(String userId);

  /// Move a saved pin to another board
  Future<Either<Failure, bool>> movePinToBoard({
    required String userId,
    required String savedPinId,
    required String toBoardId,
  });

  /// Sync unsynced saved pins with cloud
  Future<Either<Failure, void>> syncUnsyncedPins();
}
