import 'package:clerk_auth/clerk_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile_model.dart';
import '../services/auth_sync_service.dart';

/// Provider for the current user profile
final currentUserProfileProvider =
    StateNotifierProvider<CurrentUserNotifier, UserProfileModel?>((ref) {
      return CurrentUserNotifier();
    });

/// State notifier for current user
class CurrentUserNotifier extends StateNotifier<UserProfileModel?> {
  CurrentUserNotifier() : super(null) {
    // Load from local storage on init
    _loadFromLocal();
  }

  void _loadFromLocal() {
    final profile = AuthSyncService.getCurrentUserProfile();
    if (profile != null) {
      state = profile;
    }
  }

  /// Sync user after Clerk authentication
  Future<void> syncUser(User clerkUser) async {
    final profile = await AuthSyncService.syncUserAfterAuth(clerkUser);
    if (profile != null) {
      state = profile;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? website,
    String? avatarUrl,
  }) async {
    final updatedProfile = await AuthSyncService.updateUserProfile(
      username: username,
      fullName: fullName,
      bio: bio,
      website: website,
      avatarUrl: avatarUrl,
    );
    if (updatedProfile != null) {
      state = updatedProfile;
    }
  }

  /// Clear user on logout
  Future<void> clearUser() async {
    await AuthSyncService.clearUserSession();
    state = null;
  }

  /// Refresh from cloud
  Future<void> refreshFromCloud() async {
    final userId = AuthSyncService.getCurrentUserId();
    if (userId != null) {
      await AuthSyncService.syncFromCloud(userId);
      _loadFromLocal();
    }
  }
}

/// Provider for current user ID (convenience)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProfileProvider)?.clerkUserId;
});

/// Provider to check if user is logged in
final isUserLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProfileProvider) != null;
});
