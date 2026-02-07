import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Abstract repository interface for likes - defines the contract
abstract class LikeRepository {
  /// Like a pin
  Future<Either<Failure, bool>> likePin({
    required String userId,
    required String pinId,
  });

  /// Unlike a pin
  Future<Either<Failure, bool>> unlikePin({
    required String userId,
    required String pinId,
  });

  /// Toggle like status
  Future<Either<Failure, bool>> toggleLike({
    required String userId,
    required String pinId,
  });

  /// Check if a pin is liked (sync - local only)
  bool isPinLiked({required String userId, required String pinId});

  /// Check if a pin is liked (async - with cloud fallback)
  Future<Either<Failure, bool>> isPinLikedAsync({
    required String userId,
    required String pinId,
  });

  /// Get all liked pin IDs for a user
  List<String> getUserLikedPinIds(String userId);

  /// Sync unsynced likes with cloud
  Future<Either<Failure, void>> syncUnsyncedLikes();
}
