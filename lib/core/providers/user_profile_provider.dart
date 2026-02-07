import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile_model.dart';
import '../repositories/user_profile_repository.dart';
import 'user_provider.dart';

/// State for user profile
class UserProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final String? error;

  const UserProfileState({this.profile, this.isLoading = false, this.error});

  UserProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing user profile state
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final String? clerkUserId;

  UserProfileNotifier(this.clerkUserId) : super(const UserProfileState()) {
    if (clerkUserId != null) {
      loadProfile();
    }
  }

  /// Load user profile
  Future<void> loadProfile() async {
    if (clerkUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await UserProfileRepository.getUserProfile(clerkUserId!);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create or update profile
  Future<UserProfileModel?> upsertProfile({
    required String email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
  }) async {
    if (clerkUserId == null) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await UserProfileRepository.upsertProfile(
        clerkUserId: clerkUserId!,
        email: email,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
        website: website,
      );

      state = state.copyWith(profile: profile, isLoading: false);
      return profile;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Update profile
  Future<UserProfileModel?> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
  }) async {
    if (clerkUserId == null) return null;

    try {
      final profile = await UserProfileRepository.updateProfile(
        clerkUserId: clerkUserId!,
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
        website: website,
      );

      if (profile != null) {
        state = state.copyWith(profile: profile);
      }

      return profile;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Clear profile on logout
  Future<void> clearProfile() async {
    if (clerkUserId != null) {
      await UserProfileRepository.clearUserProfile(clerkUserId!);
    }
    state = const UserProfileState();
  }
}

/// Provider for user profile
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      return UserProfileNotifier(userId);
    });

/// Provider for profile display name
final profileDisplayNameProvider = Provider<String>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.displayName ?? 'User';
});

/// Provider for profile avatar URL
final profileAvatarUrlProvider = Provider<String?>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.profile?.avatarUrl;
});
