import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/models/saved_pin_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/model_extensions.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../domain/entities/saved_pin.dart';
import '../../domain/repositories/saved_pin_repository.dart';
import '../datasources/saved_pin_local_datasource.dart';
import '../datasources/saved_pin_remote_datasource.dart';

/// Implementation of SavedPinRepository
class SavedPinRepositoryImpl implements SavedPinRepository {
  final SavedPinLocalDataSource _localDataSource;
  final SavedPinRemoteDataSource _remoteDataSource;
  static const _uuid = Uuid();

  SavedPinRepositoryImpl({
    required SavedPinLocalDataSource localDataSource,
    required SavedPinRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, SavedPin>> savePin({
    required String userId,
    required Pin pin,
    required String boardId,
  }) async {
    // Create saved pin locally first (optimistic update)
    final localSavedPin = SavedPinModel(
      id: _uuid.v4(),
      pinId: pin.id,
      boardId: boardId,
      userId: userId,
      imageUrl: pin.imageUrl,
      thumbnailUrl: pin.thumbnailUrl,
      title: pin.title,
      description: pin.description,
      link: pin.link,
      width: pin.width,
      height: pin.height,
      photographer: pin.photographer,
      avgColor: pin.avgColor,
      savedAt: DateTime.now(),
      isSynced: false,
    );

    await _localDataSource.savePin(localSavedPin);

    // Try to sync with cloud
    try {
      final cloudResponse = await _remoteDataSource.savePin(
        userId: userId,
        pinId: pin.id,
        boardId: boardId,
        imageUrl: pin.imageUrl,
        thumbnailUrl: pin.thumbnailUrl,
        title: pin.title,
        description: pin.description,
        link: pin.link,
        width: pin.width,
        height: pin.height,
        photographer: pin.photographer,
        avgColor: pin.avgColor,
      );

      final syncedPin = SavedPinModel.fromJson(cloudResponse);
      await _localDataSource.savePin(syncedPin);
      // Delete the local unsaved version if IDs differ
      if (syncedPin.id != localSavedPin.id) {
        await _localDataSource.deleteSavedPin(localSavedPin.id);
      }
      return Right(syncedPin.toEntity());
    } catch (e) {
      // Return local version if cloud fails
      return Right(localSavedPin.toEntity());
    }
  }

  @override
  Future<Either<Failure, bool>> unsavePin({
    required String userId,
    required String pinId,
    required String boardId,
  }) async {
    // Delete locally first
    await _localDataSource.unsavePin(userId, pinId);

    // Try to delete from cloud
    try {
      await _remoteDataSource.unsavePin(
        userId: userId,
        pinId: pinId,
        boardId: boardId,
      );
      return const Right(true);
    } catch (e) {
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, List<SavedPin>>> getBoardPins(String boardId) async {
    // Return local pins first
    final localPins = _localDataSource.getBoardPins(boardId);

    // Try to fetch from cloud
    try {
      final cloudPins = await _remoteDataSource.getBoardPins(boardId);
      final syncedPins =
          cloudPins.map((json) => SavedPinModel.fromJson(json)).toList();
      await _localDataSource.savePins(syncedPins);
      return Right(syncedPins.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Right(localPins.map((m) => m.toEntity()).toList());
    }
  }

  @override
  Future<Either<Failure, List<SavedPin>>> getUserSavedPins(
    String userId,
  ) async {
    final localPins = _localDataSource.getUserSavedPins(userId);

    try {
      final cloudPins = await _remoteDataSource.getUserSavedPins(userId);
      final syncedPins =
          cloudPins.map((json) => SavedPinModel.fromJson(json)).toList();
      await _localDataSource.savePins(syncedPins);
      return Right(syncedPins.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Right(localPins.map((m) => m.toEntity()).toList());
    }
  }

  @override
  bool isPinSaved({required String userId, required String pinId}) {
    return _localDataSource.isPinSaved(userId, pinId);
  }

  @override
  Future<Either<Failure, bool>> isPinSavedAsync({
    required String userId,
    required String pinId,
  }) async {
    // Check local first
    if (_localDataSource.isPinSaved(userId, pinId)) {
      return const Right(true);
    }

    // Check cloud as fallback
    try {
      final isSaved = await _remoteDataSource.isPinSaved(
        userId: userId,
        pinId: pinId,
      );
      return Right(isSaved);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  String? getPinBoardId(String userId, String pinId) {
    return _localDataSource.getPinBoardId(userId, pinId);
  }

  @override
  Set<String> getSavedPinIds(String userId) {
    return _localDataSource.getSavedPinIds(userId);
  }

  @override
  Future<Either<Failure, bool>> movePinToBoard({
    required String userId,
    required String savedPinId,
    required String toBoardId,
  }) async {
    // Update locally first
    await _localDataSource.updateSavedPinBoard(savedPinId, toBoardId);

    // Try to sync with cloud
    try {
      await _remoteDataSource.updateSavedPinBoard(
        savedPinId: savedPinId,
        toBoardId: toBoardId,
      );
      return const Right(true);
    } catch (e) {
      // Local update still succeeded
      return const Right(true);
    }
  }

  @override
  Future<Either<Failure, void>> syncUnsyncedPins() async {
    try {
      final unsyncedPins = _localDataSource.getUnsyncedSavedPins();

      for (final pin in unsyncedPins) {
        try {
          final cloudResponse = await _remoteDataSource.savePin(
            userId: pin.userId,
            pinId: pin.pinId,
            boardId: pin.boardId,
            imageUrl: pin.imageUrl,
            thumbnailUrl: pin.thumbnailUrl,
            title: pin.title,
            description: pin.description,
            link: pin.link,
            width: pin.width,
            height: pin.height,
            photographer: pin.photographer,
            avgColor: pin.avgColor,
          );

          final syncedPin = SavedPinModel.fromJson(cloudResponse);
          await _localDataSource.savePin(syncedPin);
          await _localDataSource.deleteSavedPin(pin.id);
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
final savedPinLocalDataSourceProvider = Provider<SavedPinLocalDataSource>((
  ref,
) {
  return SavedPinLocalDataSourceImpl();
});

/// Provider for remote data source
final savedPinRemoteDataSourceProvider = Provider<SavedPinRemoteDataSource>((
  ref,
) {
  return SavedPinRemoteDataSourceImpl(Supabase.instance.client);
});

/// Provider for the repository
final savedPinRepositoryProvider = Provider<SavedPinRepository>((ref) {
  return SavedPinRepositoryImpl(
    localDataSource: ref.watch(savedPinLocalDataSourceProvider),
    remoteDataSource: ref.watch(savedPinRemoteDataSourceProvider),
  );
});
