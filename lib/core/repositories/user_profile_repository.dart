import 'package:uuid/uuid.dart';

import '../data/models/user_profile_model.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';

/// Repository for managing user profiles with cloud sync and local caching
class UserProfileRepository {
  static const _uuid = Uuid();

  /// Create or update user profile
  static Future<UserProfileModel> upsertProfile({
    required String clerkUserId,
    required String email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
  }) async {
    // Create profile locally first
    final localProfile = UserProfileModel(
      id: _uuid.v4(),
      clerkUserId: clerkUserId,
      email: email,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      website: website,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await LocalStorageService.saveUserProfile(localProfile);

    // Try to sync with cloud
    try {
      final cloudResponse = await SupabaseService.upsertUserProfile(
        clerkUserId: clerkUserId,
        email: email,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
        website: website,
      );

      final syncedProfile = UserProfileModel.fromJson(cloudResponse);
      await LocalStorageService.saveUserProfile(syncedProfile);
      return syncedProfile;
    } catch (e) {
      return localProfile;
    }
  }

  /// Get user profile
  static Future<UserProfileModel?> getUserProfile(String clerkUserId) async {
    // Get local profile first
    final localProfile = LocalStorageService.getUserProfile(clerkUserId);
    if (localProfile != null && localProfile.id.isNotEmpty) {
      // Return local immediately, then try to update from cloud
      _fetchAndCacheCloudProfile(clerkUserId);
      return localProfile;
    }

    // If no local profile, try cloud
    try {
      final cloudProfile = await SupabaseService.getUserProfile(clerkUserId);
      if (cloudProfile != null) {
        final profile = UserProfileModel.fromJson(cloudProfile);
        await LocalStorageService.saveUserProfile(profile);
        return profile;
      }
    } catch (e) {
      // Return null if no profile found
    }

    return null;
  }

  /// Fetch profile from cloud and cache locally (background)
  static Future<void> _fetchAndCacheCloudProfile(String clerkUserId) async {
    try {
      final cloudProfile = await SupabaseService.getUserProfile(clerkUserId);
      if (cloudProfile != null) {
        final profile = UserProfileModel.fromJson(cloudProfile);
        await LocalStorageService.saveUserProfile(profile);
      }
    } catch (e) {
      // Ignore errors in background fetch
    }
  }

  /// Update user profile
  static Future<UserProfileModel?> updateProfile({
    required String clerkUserId,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
  }) async {
    final localProfile = LocalStorageService.getUserProfile(clerkUserId);
    if (localProfile == null || localProfile.id.isEmpty) {
      return null;
    }

    final updatedProfile = localProfile.copyWith(
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      website: website,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await LocalStorageService.saveUserProfile(updatedProfile);

    // Try to sync with cloud
    try {
      final cloudResponse = await SupabaseService.upsertUserProfile(
        clerkUserId: clerkUserId,
        email: localProfile.email,
        username: username ?? localProfile.username,
        fullName: fullName ?? localProfile.fullName,
        avatarUrl: avatarUrl ?? localProfile.avatarUrl,
        bio: bio ?? localProfile.bio,
        website: website ?? localProfile.website,
      );

      final syncedProfile = UserProfileModel.fromJson(cloudResponse);
      await LocalStorageService.saveUserProfile(syncedProfile);
      return syncedProfile;
    } catch (e) {
      return updatedProfile;
    }
  }

  /// Follow a user
  static Future<bool> followUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await SupabaseService.followUser(
        followerId: followerId,
        followingId: followingId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Unfollow a user
  static Future<bool> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await SupabaseService.unfollowUser(
        followerId: followerId,
        followingId: followingId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get followers count
  static Future<int> getFollowersCount(String userId) async {
    try {
      return await SupabaseService.getFollowersCount(userId);
    } catch (e) {
      return 0;
    }
  }

  /// Get following count
  static Future<int> getFollowingCount(String userId) async {
    try {
      return await SupabaseService.getFollowingCount(userId);
    } catch (e) {
      return 0;
    }
  }

  /// Clear user profile on logout
  static Future<void> clearUserProfile(String clerkUserId) async {
    await LocalStorageService.deleteUserProfile(clerkUserId);
  }
}
