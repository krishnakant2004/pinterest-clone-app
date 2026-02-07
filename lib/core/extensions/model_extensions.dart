import '../data/models/board_model.dart';
import '../data/models/like_model.dart';
import '../data/models/saved_pin_model.dart';
import '../../features/boards/domain/entities/board.dart';
import '../../features/likes/domain/entities/like.dart';
import '../../features/saved_pins/domain/entities/saved_pin.dart';

/// Extension to convert BoardModel to Board entity
extension BoardModelX on BoardModel {
  Board toEntity() {
    return Board(
      id: id,
      name: name,
      description: description,
      coverImageUrl: coverImageUrl,
      pinCount: pinCount,
      isPrivate: isPrivate,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      collaboratorIds: collaboratorIds,
    );
  }
}

/// Extension to convert LikeModel to Like entity
extension LikeModelX on LikeModel {
  Like toEntity() {
    return Like(id: id, pinId: pinId, userId: userId, createdAt: createdAt);
  }
}

/// Extension to convert SavedPinModel to SavedPin entity
extension SavedPinModelX on SavedPinModel {
  SavedPin toEntity() {
    return SavedPin(
      id: id,
      pinId: pinId,
      boardId: boardId,
      userId: userId,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
      link: link,
      width: width,
      height: height,
      photographer: photographer,
      avgColor: avgColor,
      savedAt: savedAt,
    );
  }
}
