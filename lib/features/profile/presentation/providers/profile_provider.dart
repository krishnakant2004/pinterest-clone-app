import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/user_profile_model.dart';
import '../../../../core/providers/user_provider.dart';

class ProfileState {
  final String? id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.id,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isLoading = false,
    this.error,
  });

  /// Create ProfileState from UserProfileModel
  factory ProfileState.fromUserProfile(UserProfileModel user) {
    return ProfileState(
      id: user.clerkUserId,
      email: user.email,
      username: user.username,
      displayName: user.fullName,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      followersCount: 0, // TODO: Fetch from database
      followingCount: 0, // TODO: Fetch from database
    );
  }

  ProfileState copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileNotifier(this._ref) : super(const ProfileState()) {
    // Listen to currentUserProfileProvider and update state
    _ref.listen<UserProfileModel?>(currentUserProfileProvider, (
      previous,
      next,
    ) {
      if (next != null) {
        state = ProfileState.fromUserProfile(next);
      }
    });

    // Initialize with current user if available
    final currentUser = _ref.read(currentUserProfileProvider);
    if (currentUser != null) {
      state = ProfileState.fromUserProfile(currentUser);
    }
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);

    // Refresh from the current user provider
    await _ref.read(currentUserProfileProvider.notifier).refreshFromCloud();

    final currentUser = _ref.read(currentUserProfileProvider);
    if (currentUser != null) {
      state = ProfileState.fromUserProfile(
        currentUser,
      ).copyWith(isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
  }) {
    state = state.copyWith(
      displayName: displayName,
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref);
});
