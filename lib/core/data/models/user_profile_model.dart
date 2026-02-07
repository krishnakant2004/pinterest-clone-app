import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 3)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clerkUserId;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? username;

  @HiveField(4)
  final String? fullName;

  @HiveField(5)
  final String? avatarUrl;

  @HiveField(6)
  final String? bio;

  @HiveField(7)
  final String? website;

  @HiveField(8)
  final int followersCount;

  @HiveField(9)
  final int followingCount;

  @HiveField(10)
  final DateTime? createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final bool isSynced;

  UserProfileModel({
    required this.id,
    required this.clerkUserId,
    required this.email,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.website,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isSynced = false,
  });

  /// Create from JSON (Supabase response)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      clerkUserId: json['clerk_user_id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      isSynced: true,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clerk_user_id': clerkUserId,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'website': website,
      'followers_count': followersCount,
      'following_count': followingCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get displayName => fullName ?? username ?? email.split('@').first;

  UserProfileModel copyWith({
    String? id,
    String? clerkUserId,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? website,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      clerkUserId: clerkUserId ?? this.clerkUserId,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
