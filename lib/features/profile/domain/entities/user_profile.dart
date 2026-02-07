import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? website;
  final int followersCount;
  final int followingCount;
  final int pinsCount;
  final int boardsCount;
  final bool isFollowing;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.website,
    this.followersCount = 0,
    this.followingCount = 0,
    this.pinsCount = 0,
    this.boardsCount = 0,
    this.isFollowing = false,
    this.createdAt,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    if (username != null && username!.isNotEmpty) {
      return username![0].toUpperCase();
    }
    return '?';
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? website,
    int? followersCount,
    int? followingCount,
    int? pinsCount,
    int? boardsCount,
    bool? isFollowing,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      pinsCount: pinsCount ?? this.pinsCount,
      boardsCount: boardsCount ?? this.boardsCount,
      isFollowing: isFollowing ?? this.isFollowing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    displayName,
    avatarUrl,
    bio,
    website,
    followersCount,
    followingCount,
    pinsCount,
    boardsCount,
    isFollowing,
    createdAt,
  ];
}
