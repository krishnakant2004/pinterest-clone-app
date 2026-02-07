import 'package:hive/hive.dart';

import '../../../../core/data/models/like_model.dart';

/// Local data source for likes using Hive
abstract class LikeLocalDataSource {
  /// Like a pin locally
  Future<void> likePin(LikeModel like);

  /// Unlike a pin locally
  Future<void> unlikePin(String oddsUserId, String pinId);

  /// Check if a pin is liked
  bool isPinLiked(String userId, String pinId);

  /// Get all liked pin IDs for a user
  List<String> getUserLikedPinIds(String userId);

  /// Get all unsynced likes
  List<LikeModel> getUnsyncedLikes();

  /// Update like sync status
  Future<void> updateSyncStatus(String oddsId, bool isSynced);
}

/// Implementation of LikeLocalDataSource using Hive
class LikeLocalDataSourceImpl implements LikeLocalDataSource {
  static const String _boxName = 'likes';

  Box<LikeModel> get _box => Hive.box<LikeModel>(_boxName);

  @override
  Future<void> likePin(LikeModel like) async {
    await _box.put(like.id, like);
  }

  @override
  Future<void> unlikePin(String userId, String pinId) async {
    final key = '${userId}_$pinId';
    await _box.delete(key);

    // Also delete any other entries for this user-pin combo
    final keysToDelete =
        _box.keys.where((k) {
          final like = _box.get(k);
          return like?.userId == userId && like?.pinId == pinId;
        }).toList();

    for (final k in keysToDelete) {
      await _box.delete(k);
    }
  }

  @override
  bool isPinLiked(String userId, String pinId) {
    return _box.values.any(
      (like) => like.userId == userId && like.pinId == pinId,
    );
  }

  @override
  List<String> getUserLikedPinIds(String userId) {
    return _box.values
        .where((like) => like.userId == userId)
        .map((like) => like.pinId)
        .toList();
  }

  @override
  List<LikeModel> getUnsyncedLikes() {
    return _box.values.where((like) => !like.isSynced).toList();
  }

  @override
  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final like = _box.get(id);
    if (like != null) {
      await _box.put(id, like.copyWith(isSynced: isSynced));
    }
  }
}
