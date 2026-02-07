import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/models/like_model.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/like_repository.dart';
import '../datasources/like_local_datasource.dart';
import '../datasources/like_remote_datasource.dart';

/// Implementation of LikeRepository
class LikeRepositoryImpl implements LikeRepository {
  final LikeLocalDataSource _localDataSource;
  final LikeRemoteDataSource _remoteDataSource;

  LikeRepositoryImpl({
    required LikeLocalDataSource localDataSource,
    required LikeRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, bool>> likePin({
    required String userId,
    required String pinId,
  }) async {
    // Check if already liked locally
    if (_localDataSource.isPinLiked(userId, pinId)) {
      return const Right(true);
    }

    // Create like locally first (optimistic update)
    final localLike = LikeModel(
      id: '${userId}_$pinId',
      pinId: pinId,
      userId: userId,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await _localDataSource.likePin(localLike);

    // Try to sync with cloud
    try {
      await _remoteDataSource.likePin(userId: userId, pinId: pinId);
      await _localDataSource.updateSyncStatus(localLike.id, true);
      return const Right(true);
    } catch (e) {
      // Still return success - liked locally
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, bool>> unlikePin({
    required String userId,
    required String pinId,
  }) async {
    // Delete locally first
    await _localDataSource.unlikePin(userId, pinId);

    // Try to delete from cloud
    try {
      await _remoteDataSource.unlikePin(userId: userId, pinId: pinId);
      return const Right(true);
    } catch (e) {
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, bool>> toggleLike({
    required String userId,
    required String pinId,
  }) async {
    if (isPinLiked(userId: userId, pinId: pinId)) {
      return unlikePin(userId: userId, pinId: pinId);
    } else {
      return likePin(userId: userId, pinId: pinId);
    }
  }

  @override
  bool isPinLiked({required String userId, required String pinId}) {
    return _localDataSource.isPinLiked(userId, pinId);
  }

  @override
  Future<Either<Failure, bool>> isPinLikedAsync({
    required String userId,
    required String pinId,
  }) async {
    // Check local first
    if (_localDataSource.isPinLiked(userId, pinId)) {
      return const Right(true);
    }

    // Check cloud as fallback
    try {
      final isLiked = await _remoteDataSource.isPinLiked(
        userId: userId,
        pinId: pinId,
      );
      return Right(isLiked);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  List<String> getUserLikedPinIds(String userId) {
    return _localDataSource.getUserLikedPinIds(userId);
  }

  @override
  Future<Either<Failure, void>> syncUnsyncedLikes() async {
    try {
      final unsyncedLikes = _localDataSource.getUnsyncedLikes();

      for (final like in unsyncedLikes) {
        try {
          await _remoteDataSource.likePin(
            userId: like.userId,
            pinId: like.pinId,
          );
          await _localDataSource.updateSyncStatus(like.id, true);
        } catch (_) {
          // Continue with next item
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

/// Provider for local data source
final likeLocalDataSourceProvider = Provider<LikeLocalDataSource>((ref) {
  return LikeLocalDataSourceImpl();
});

/// Provider for remote data source
final likeRemoteDataSourceProvider = Provider<LikeRemoteDataSource>((ref) {
  return LikeRemoteDataSourceImpl(Supabase.instance.client);
});

/// Provider for the repository
final likeRepositoryProvider = Provider<LikeRepository>((ref) {
  return LikeRepositoryImpl(
    localDataSource: ref.watch(likeLocalDataSourceProvider),
    remoteDataSource: ref.watch(likeRemoteDataSourceProvider),
  );
});
