import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';
import '../datasources/pin_remote_data_source.dart';

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return PinRepositoryImpl(ref.watch(pinRemoteDataSourceProvider));
});

class PinRepositoryImpl implements PinRepository {
  final PinRemoteDataSource _remoteDataSource;

  PinRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Pin>>> getCuratedPins({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final pins = await _remoteDataSource.getCuratedPhotos(
        page: page,
        perPage: perPage,
      );
      return Right(pins);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Pin>>> searchPins({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final pins = await _remoteDataSource.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
      );
      return Right(pins);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Pin>> getPinById(String id) async {
    try {
      final pin = await _remoteDataSource.getPhotoById(id);
      return Right(pin);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePin(Pin pin, String boardId) async {
    // TODO: Implement save to local storage/backend
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unsavePin(String pinId) async {
    // TODO: Implement unsave from local storage/backend
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Pin>>> getSavedPins() async {
    // TODO: Implement get saved pins from local storage/backend
    return const Right([]);
  }
}
