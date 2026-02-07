import 'package:clerk_auth/clerk_auth.dart';

import '../data/models/user_profile_model.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

/// Service to sync Clerk authenticated user with Supabase and Local Storage
class AuthSyncService {
  /// Sync user after successful Clerk authentication
  /// This creates/updates the user profile in both Supabase and local Hive storage
  static Future<UserProfileModel?> syncUserAfterAuth(User clerkUser) async {
    try {
      final clerkUserId = clerkUser.id;
      // Get email from emailAddresses list
      final email = clerkUser.emailAddresses?.firstOrNull?.emailAddress ?? '';
      final fullName =
          '${clerkUser.firstName ?? ''} ${clerkUser.lastName ?? ''}'.trim();
      final username = clerkUser.username;
      final avatarUrl = clerkUser.profileImageUrl ?? clerkUser.imageUrl;

      // 1. Upsert user profile in Supabase
      Map<String, dynamic>? supabaseProfile;
      try {
        supabaseProfile = await SupabaseService.upsertUserProfile(
          clerkUserId: clerkUserId,
          email: email,
          username: username,
          fullName: fullName.isNotEmpty ? fullName : null,
          avatarUrl: avatarUrl,
        );
      } catch (e) {
        // If Supabase fails (tables not created yet), continue with local storage
        print('Supabase sync failed (tables may not exist): $e');
      }

      // 2. Create local user profile model
      final userProfile = UserProfileModel(
        id: supabaseProfile?['id'] ?? clerkUserId,
        clerkUserId: clerkUserId,
        email: email,
        username: username,
        fullName: fullName.isNotEmpty ? fullName : null,
        avatarUrl: avatarUrl,
        followersCount: supabaseProfile?['followers_count'] ?? 0,
        followingCount: supabaseProfile?['following_count'] ?? 0,
        createdAt:
            supabaseProfile?['created_at'] != null
                ? DateTime.parse(supabaseProfile!['created_at'])
                : DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: supabaseProfile != null,
      );

      // 3. Save to local Hive storage
      await LocalStorageService.saveUserProfile(userProfile);

      // 4. Store the Clerk user ID for future reference
      await LocalStorageService.saveSetting('current_user_id', clerkUserId);
      await LocalStorageService.saveSetting('user_email', email);

      print('User synced successfully: $clerkUserId');
      return userProfile;
    } catch (e) {
      print('Error syncing user: $e');
      return null;
    }
  }

  /// Get current user profile from local storage
  static UserProfileModel? getCurrentUserProfile() {
    final clerkUserId = LocalStorageService.getSetting<String>(
      'current_user_id',
    );
    if (clerkUserId == null || clerkUserId.isEmpty) return null;

    final profile = LocalStorageService.getUserProfile(clerkUserId);
    if (profile?.id.isEmpty ?? true) return null;

    return profile;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return LocalStorageService.getSetting<String>('current_user_id');
  }

  /// Sync user data from Supabase to local storage
  static Future<void> syncFromCloud(String clerkUserId) async {
    try {
      // Fetch profile from Supabase
      final supabaseProfile = await SupabaseService.getUserProfile(clerkUserId);
      if (supabaseProfile != null) {
        final userProfile = UserProfileModel.fromJson(supabaseProfile);
        await LocalStorageService.saveUserProfile(userProfile);
      }

      // Note: Boards, SavedPins, and Likes sync is handled by their respective
      // feature repositories (BoardRepository, SavedPinRepository, LikeRepository)

      print('Synced profile from cloud for user: $clerkUserId');
    } catch (e) {
      print('Error syncing from cloud: $e');
    }
  }

  /// Clear user session on logout
  static Future<void> clearUserSession() async {
    final userId = getCurrentUserId();
    if (userId != null) {
      await LocalStorageService.clearUserData(userId);
    }
    await LocalStorageService.deleteSetting('current_user_id');
    await LocalStorageService.deleteSetting('user_email');
    print('User session cleared');
  }

  /// Check if user is logged in locally
  static bool isUserLoggedIn() {
    final userId = getCurrentUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Update user profile
  static Future<UserProfileModel?> updateUserProfile({
    String? username,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
  }) async {
    try {
      final clerkUserId = getCurrentUserId();
      if (clerkUserId == null) return null;

      final currentProfile = LocalStorageService.getUserProfile(clerkUserId);
      if (currentProfile == null || currentProfile.id.isEmpty) return null;

      // Update in Supabase
      try {
        await SupabaseService.upsertUserProfile(
          clerkUserId: clerkUserId,
          email: currentProfile.email,
          username: username ?? currentProfile.username,
          fullName: fullName ?? currentProfile.fullName,
          bio: bio ?? currentProfile.bio,
          website: website ?? currentProfile.website,
          avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
        );
      } catch (e) {
        print('Supabase update failed: $e');
      }

      // Update local profile
      final updatedProfile = UserProfileModel(
        id: currentProfile.id,
        clerkUserId: clerkUserId,
        email: currentProfile.email,
        username: username ?? currentProfile.username,
        fullName: fullName ?? currentProfile.fullName,
        avatarUrl: avatarUrl ?? currentProfile.avatarUrl,
        bio: bio ?? currentProfile.bio,
        website: website ?? currentProfile.website,
        followersCount: currentProfile.followersCount,
        followingCount: currentProfile.followingCount,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
        isSynced: true,
      );

      await LocalStorageService.saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }
}
