import 'package:hive/hive.dart';

import '../../../../core/data/models/saved_pin_model.dart';

/// Local data source for saved pins using Hive
abstract class SavedPinLocalDataSource {
  /// Save a pin locally
  Future<void> savePin(SavedPinModel savedPin);

  /// Save multiple pins locally
  Future<void> savePins(List<SavedPinModel> pins);

  /// Delete a saved pin locally
  Future<void> deleteSavedPin(String id);

  /// Unsave a pin by user and pin ID
  Future<void> unsavePin(String userId, String pinId);

  /// Get saved pins for a board
  List<SavedPinModel> getBoardPins(String boardId);

  /// Get all saved pins for a user
  List<SavedPinModel> getUserSavedPins(String userId);

  /// Check if a pin is saved
  bool isPinSaved(String userId, String pinId);

  /// Get the board ID where a pin is saved
  String? getPinBoardId(String userId, String pinId);

  /// Get all saved pin IDs for a user
  Set<String> getSavedPinIds(String userId);

  /// Get all unsynced saved pins
  List<SavedPinModel> getUnsyncedSavedPins();

  /// Update saved pin board
  Future<void> updateSavedPinBoard(String savedPinId, String toBoardId);
}

/// Implementation of SavedPinLocalDataSource using Hive
class SavedPinLocalDataSourceImpl implements SavedPinLocalDataSource {
  static const String _boxName = 'saved_pins';

  Box<SavedPinModel> get _box => Hive.box<SavedPinModel>(_boxName);

  @override
  Future<void> savePin(SavedPinModel savedPin) async {
    await _box.put(savedPin.id, savedPin);
  }

  @override
  Future<void> savePins(List<SavedPinModel> pins) async {
    for (final pin in pins) {
      await _box.put(pin.id, pin);
    }
  }

  @override
  Future<void> deleteSavedPin(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> unsavePin(String userId, String pinId) async {
    final keysToDelete =
        _box.keys.where((key) {
          final pin = _box.get(key);
          return pin?.userId == userId && pin?.pinId == pinId;
        }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  @override
  List<SavedPinModel> getBoardPins(String boardId) {
    return _box.values.where((pin) => pin.boardId == boardId).toList()..sort(
      (a, b) => (b.savedAt ?? DateTime(0)).compareTo(a.savedAt ?? DateTime(0)),
    );
  }

  @override
  List<SavedPinModel> getUserSavedPins(String userId) {
    return _box.values.where((pin) => pin.userId == userId).toList()..sort(
      (a, b) => (b.savedAt ?? DateTime(0)).compareTo(a.savedAt ?? DateTime(0)),
    );
  }

  @override
  bool isPinSaved(String userId, String pinId) {
    return _box.values.any((pin) => pin.userId == userId && pin.pinId == pinId);
  }

  @override
  String? getPinBoardId(String userId, String pinId) {
    try {
      return _box.values
          .firstWhere((pin) => pin.userId == userId && pin.pinId == pinId)
          .boardId;
    } catch (_) {
      return null;
    }
  }

  @override
  Set<String> getSavedPinIds(String userId) {
    return _box.values
        .where((pin) => pin.userId == userId)
        .map((pin) => pin.pinId)
        .toSet();
  }

  @override
  List<SavedPinModel> getUnsyncedSavedPins() {
    return _box.values.where((pin) => !pin.isSynced).toList();
  }

  @override
  Future<void> updateSavedPinBoard(String savedPinId, String toBoardId) async {
    final pin = _box.get(savedPinId);
    if (pin != null) {
      await _box.put(
        savedPinId,
        pin.copyWith(boardId: toBoardId, isSynced: false),
      );
    }
  }
}
