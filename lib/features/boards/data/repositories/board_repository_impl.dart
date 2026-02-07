import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/models/board_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/model_extensions.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_local_datasource.dart';
import '../datasources/board_remote_datasource.dart';

/// Implementation of BoardRepository
class BoardRepositoryImpl implements BoardRepository {
  final BoardLocalDataSource _localDataSource;
  final BoardRemoteDataSource _remoteDataSource;
  static const _uuid = Uuid();

  BoardRepositoryImpl({
    required BoardLocalDataSource localDataSource,
    required BoardRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Board>> createBoard({
    required String userId,
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    // Create board locally first (optimistic update)
    final localBoard = BoardModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      isPrivate: isPrivate,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _localDataSource.saveBoard(localBoard);

    // Try to sync with cloud
    try {
      final cloudResponse = await _remoteDataSource.createBoard(
        userId: userId,
        name: name,
        description: description,
        isPrivate: isPrivate,
      );

      final syncedBoard = BoardModel.fromJson(cloudResponse);
      await _localDataSource.saveBoard(syncedBoard);
      // Delete the local unsaved version if IDs differ
      if (syncedBoard.id != localBoard.id) {
        await _localDataSource.deleteBoard(localBoard.id);
      }
      return Right(syncedBoard.toEntity());
    } catch (e) {
      // Return local version if cloud fails
      return Right(localBoard.toEntity());
    }
  }

  @override
  Future<Either<Failure, Board>> updateBoard({
    required String boardId,
    String? name,
    String? description,
    String? coverImageUrl,
    bool? isPrivate,
  }) async {
    // Get current board
    final currentBoard = _localDataSource.getBoard(boardId);
    if (currentBoard == null) {
      return Left(CacheFailure(message: 'Board not found'));
    }

    // Update locally first
    final updatedBoard = currentBoard.copyWith(
      name: name,
      description: description,
      coverImageUrl: coverImageUrl,
      isPrivate: isPrivate,
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await _localDataSource.saveBoard(updatedBoard);

    // Try to sync with cloud
    try {
      final cloudResponse = await _remoteDataSource.updateBoard(
        boardId: boardId,
        name: name,
        description: description,
        coverImageUrl: coverImageUrl,
        isPrivate: isPrivate,
      );

      final syncedBoard = BoardModel.fromJson(cloudResponse);
      await _localDataSource.saveBoard(syncedBoard);
      return Right(syncedBoard.toEntity());
    } catch (e) {
      return Right(updatedBoard.toEntity());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBoard(String boardId) async {
    // Delete locally first
    await _localDataSource.deleteBoard(boardId);

    // Try to delete from cloud
    try {
      await _remoteDataSource.deleteBoard(boardId);
      return const Right(true);
    } catch (e) {
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, List<Board>>> getUserBoards(String userId) async {
    // Return local boards first
    final localBoards = _localDataSource.getUserBoards(userId);

    // Try to fetch from cloud
    try {
      final cloudBoards = await _remoteDataSource.getUserBoards(userId);
      final syncedBoards =
          cloudBoards.map((json) => BoardModel.fromJson(json)).toList();
      await _localDataSource.saveBoards(syncedBoards);
      return Right(syncedBoards.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Right(localBoards.map((m) => m.toEntity()).toList());
    }
  }

  @override
  Board? getBoard(String boardId) {
    return _localDataSource.getBoard(boardId)?.toEntity();
  }

  @override
  Future<Either<Failure, Board?>> getBoardAsync(String boardId) async {
    // Check local first
    final localBoard = _localDataSource.getBoard(boardId);
    if (localBoard != null) {
      return Right(localBoard.toEntity());
    }

    // Try to fetch from cloud
    try {
      final cloudBoard = await _remoteDataSource.getBoard(boardId);
      if (cloudBoard != null) {
        final board = BoardModel.fromJson(cloudBoard);
        await _localDataSource.saveBoard(board);
        return Right(board.toEntity());
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> incrementPinCount(String boardId) async {
    await _localDataSource.updatePinCount(boardId, 1);

    try {
      await _remoteDataSource.updatePinCount(boardId, 1);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> decrementPinCount(String boardId) async {
    await _localDataSource.updatePinCount(boardId, -1);

    try {
      await _remoteDataSource.updatePinCount(boardId, -1);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateCoverImage(
    String boardId,
    String imageUrl,
  ) async {
    await _localDataSource.updateCoverImage(boardId, imageUrl);

    try {
      await _remoteDataSource.updateCoverImage(boardId, imageUrl);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> syncUnsyncedBoards() async {
    try {
      final unsyncedBoards = _localDataSource.getUnsyncedBoards();

      for (final board in unsyncedBoards) {
        try {
          final cloudResponse = await _remoteDataSource.createBoard(
            userId: board.userId,
            name: board.name,
            description: board.description,
            isPrivate: board.isPrivate,
          );

          final syncedBoard = BoardModel.fromJson(cloudResponse);
          await _localDataSource.saveBoard(syncedBoard);
          if (syncedBoard.id != board.id) {
            await _localDataSource.deleteBoard(board.id);
          }
        } catch (_) {
          // Skip failed syncs
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
final boardLocalDataSourceProvider = Provider<BoardLocalDataSource>((ref) {
  return BoardLocalDataSourceImpl();
});

/// Provider for remote data source
final boardRemoteDataSourceProvider = Provider<BoardRemoteDataSource>((ref) {
  return BoardRemoteDataSourceImpl(Supabase.instance.client);
});

/// Provider for the repository
final boardRepositoryProvider = Provider<BoardRepository>((ref) {
  return BoardRepositoryImpl(
    localDataSource: ref.watch(boardLocalDataSourceProvider),
    remoteDataSource: ref.watch(boardRemoteDataSourceProvider),
  );
});
