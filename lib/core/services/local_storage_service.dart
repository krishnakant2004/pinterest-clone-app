import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/board_model.dart';
import '../data/models/like_model.dart';
import '../data/models/saved_pin_model.dart';
import '../data/models/user_profile_model.dart';

/// Box names for Hive storage
class HiveBoxes {
  static const String boards = 'boards';
  static const String savedPins = 'saved_pins';
  static const String likes = 'likes';
  static const String userProfile = 'user_profile';
  static const String settings = 'settings';
  static const String cache = 'cache';
}

/// Local storage service using Hive
/// Note: Board, SavedPin, and Like operations are in their respective feature datasources
class LocalStorageService {
  static late Box<BoardModel> _boardsBox;
  static late Box<SavedPinModel> _savedPinsBox;
  static late Box<LikeModel> _likesBox;
  static late Box<UserProfileModel> _userProfileBox;
  static late Box<dynamic> _settingsBox;
  static late Box<dynamic> _cacheBox;

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(BoardModelAdapter());
    Hive.registerAdapter(SavedPinModelAdapter());
    Hive.registerAdapter(LikeModelAdapter());
    Hive.registerAdapter(UserProfileModelAdapter());

    // Open boxes
    _boardsBox = await Hive.openBox<BoardModel>(HiveBoxes.boards);
    _savedPinsBox = await Hive.openBox<SavedPinModel>(HiveBoxes.savedPins);
    _likesBox = await Hive.openBox<LikeModel>(HiveBoxes.likes);
    _userProfileBox = await Hive.openBox<UserProfileModel>(
      HiveBoxes.userProfile,
    );
    _settingsBox = await Hive.openBox(HiveBoxes.settings);
    _cacheBox = await Hive.openBox(HiveBoxes.cache);
  }

  // ============ USER PROFILE OPERATIONS ============

  /// Get user profile
  static UserProfileModel? getUserProfile(String clerkUserId) {
    return _userProfileBox.values.firstWhere(
      (profile) => profile.clerkUserId == clerkUserId,
      orElse: () => UserProfileModel(id: '', clerkUserId: '', email: ''),
    );
  }

  /// Save user profile locally
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    await _userProfileBox.put(profile.clerkUserId, profile);
  }

  /// Delete user profile locally
  static Future<void> deleteUserProfile(String clerkUserId) async {
    await _userProfileBox.delete(clerkUserId);
  }

  // ============ SETTINGS OPERATIONS ============

  /// Get a setting value
  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  /// Save a setting value
  static Future<void> saveSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  /// Delete a setting
  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // ============ CACHE OPERATIONS ============

  /// Get cached data
  static T? getCached<T>(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;

    // Check if expired (cache for 1 hour by default)
    final timestamp = _cacheBox.get('${key}_timestamp') as int?;
    if (timestamp != null) {
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cachedAt).inHours > 1) {
        // Cache expired
        _cacheBox.delete(key);
        _cacheBox.delete('${key}_timestamp');
        return null;
      }
    }

    return cached as T?;
  }

  /// Save data to cache
  static Future<void> cache<T>(String key, T value) async {
    await _cacheBox.put(key, value);
    await _cacheBox.put(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Clear a specific cache entry
  static Future<void> clearCache(String key) async {
    await _cacheBox.delete(key);
    await _cacheBox.delete('${key}_timestamp');
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    await _cacheBox.clear();
  }

  // ============ UTILITY OPERATIONS ============

  /// Clear all local data
  static Future<void> clearAllData() async {
    await _boardsBox.clear();
    await _savedPinsBox.clear();
    await _likesBox.clear();
    await _userProfileBox.clear();
    await _settingsBox.clear();
    await _cacheBox.clear();
  }

  /// Clear user-specific data (on logout)
  static Future<void> clearUserData(String userId) async {
    // Clear boards
    final boardKeys =
        _boardsBox.keys.where((key) {
          final board = _boardsBox.get(key);
          return board?.userId == userId;
        }).toList();
    for (final key in boardKeys) {
      await _boardsBox.delete(key);
    }

    // Clear saved pins
    final pinKeys =
        _savedPinsBox.keys.where((key) {
          final pin = _savedPinsBox.get(key);
          return pin?.userId == userId;
        }).toList();
    for (final key in pinKeys) {
      await _savedPinsBox.delete(key);
    }

    // Clear likes
    final likeKeys =
        _likesBox.keys.where((key) {
          final like = _likesBox.get(key);
          return like?.userId == userId;
        }).toList();
    for (final key in likeKeys) {
      await _likesBox.delete(key);
    }
  }
}
