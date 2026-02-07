import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/board.dart';

/// Abstract repository interface for boards
abstract class BoardRepository {
  /// Create a new board
  Future<Either<Failure, Board>> createBoard({
    required String userId,
    required String name,
    String? description,
    bool isPrivate,
  });

  /// Update an existing board
  Future<Either<Failure, Board>> updateBoard({
    required String boardId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isPrivate,
  });

  /// Delete a board
  Future<Either<Failure, bool>> deleteBoard(String boardId);

  /// Get all boards for a user
  Future<Either<Failure, List<Board>>> getUserBoards(String userId);

  /// Get a single board by ID
  Board? getBoard(String boardId);

  /// Get a single board by ID (async)
  Future<Either<Failure, Board?>> getBoardAsync(String boardId);

  /// Increment pin count for a board
  Future<Either<Failure, void>> incrementPinCount(String boardId);

  /// Decrement pin count for a board
  Future<Either<Failure, void>> decrementPinCount(String boardId);

  /// Update board cover image
  Future<Either<Failure, void>> updateCoverImage(
    String boardId,
    String imageUrl,
  );

  /// Sync unsynced boards with cloud
  Future<Either<Failure, void>> syncUnsyncedBoards();
}
