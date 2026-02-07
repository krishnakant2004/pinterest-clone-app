import 'package:hive/hive.dart';

import '../../../../core/data/models/board_model.dart';

/// Local data source for boards using Hive
abstract class BoardLocalDataSource {
  /// Save a board locally
  Future<void> saveBoard(BoardModel board);

  /// Save multiple boards locally
  Future<void> saveBoards(List<BoardModel> boards);

  /// Delete a board locally
  Future<void> deleteBoard(String boardId);

  /// Get all boards for a user
  List<BoardModel> getUserBoards(String userId);

  /// Get a single board by ID
  BoardModel? getBoard(String boardId);

  /// Get all unsynced boards
  List<BoardModel> getUnsyncedBoards();

  /// Update board pin count
  Future<void> updatePinCount(String boardId, int delta);

  /// Update board cover image
  Future<void> updateCoverImage(String boardId, String imageUrl);
}

/// Implementation of BoardLocalDataSource using Hive
class BoardLocalDataSourceImpl implements BoardLocalDataSource {
  static const String _boxName = 'boards';

  Box<BoardModel> get _box => Hive.box<BoardModel>(_boxName);

  @override
  Future<void> saveBoard(BoardModel board) async {
    await _box.put(board.id, board);
  }

  @override
  Future<void> saveBoards(List<BoardModel> boards) async {
    for (final board in boards) {
      await _box.put(board.id, board);
    }
  }

  @override
  Future<void> deleteBoard(String boardId) async {
    await _box.delete(boardId);
  }

  @override
  List<BoardModel> getUserBoards(String userId) {
    return _box.values.where((board) => board.userId == userId).toList()..sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
  }

  @override
  BoardModel? getBoard(String boardId) {
    return _box.get(boardId);
  }

  @override
  List<BoardModel> getUnsyncedBoards() {
    return _box.values.where((board) => !board.isSynced).toList();
  }

  @override
  Future<void> updatePinCount(String boardId, int delta) async {
    final board = _box.get(boardId);
    if (board != null) {
      final newCount = (board.pinCount + delta).clamp(0, 999999);
      await _box.put(
        boardId,
        board.copyWith(pinCount: newCount, isSynced: false),
      );
    }
  }

  @override
  Future<void> updateCoverImage(String boardId, String imageUrl) async {
    final board = _box.get(boardId);
    if (board != null) {
      await _box.put(
        boardId,
        board.copyWith(coverImageUrl: imageUrl, isSynced: false),
      );
    }
  }
}
