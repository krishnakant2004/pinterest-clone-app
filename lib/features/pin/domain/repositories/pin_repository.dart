import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pin.dart';

abstract class PinRepository {
  Future<Either<Failure, List<Pin>>> getCuratedPins({
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, List<Pin>>> searchPins({
    required String query,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, Pin>> getPinById(String id);

  Future<Either<Failure, void>> savePin(Pin pin, String boardId);

  Future<Either<Failure, void>> unsavePin(String pinId);

  Future<Either<Failure, List<Pin>>> getSavedPins();
}
