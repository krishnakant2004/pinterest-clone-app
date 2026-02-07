import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

/// Profile header with avatar, name, username, stats, and edit button
class ProfileHeader extends StatelessWidget {
  final ProfileState profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Avatar with edit button
          ProfileAvatar(
            avatarUrl: profile.avatarUrl,
            displayName: profile.displayName,
            size: 50,
            showEditBadge: true,
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            profile.displayName ?? 'Pinterest User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Username
          Text(
            '@${profile.username ?? 'username'}',
            style: const TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Stats
          ProfileStats(
            followersCount: profile.followersCount,
            followingCount: profile.followingCount,
          ),
          const SizedBox(height: 16),
          // Settings Button
          OutlinedButton(
            onPressed: () {
              context.push(RouteNames.settings);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

/// Profile avatar with optional edit badge
class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? displayName;
  final double size;
  final bool showEditBadge;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.displayName,
    this.size = 50,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size,
          backgroundColor: AppColors.greyLight,
          backgroundImage:
              avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
          child:
              avatarUrl == null
                  ? Text(
                    displayName?.isNotEmpty == true
                        ? displayName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: size * 0.8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey,
                    ),
                  )
                  : null,
        ),
        if (showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.greyLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, size: 16, color: AppColors.grey),
              ),
            ),
          ),
      ],
    );
  }
}

/// Profile stats (followers/following)
class ProfileStats extends StatelessWidget {
  final int followersCount;
  final int followingCount;

  const ProfileStats({
    super.key,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatItem(value: followersCount.toString(), label: 'followers'),
        const SizedBox(width: 8),
        const Text('·', style: TextStyle(color: AppColors.grey)),
        const SizedBox(width: 8),
        StatItem(value: followingCount.toString(), label: 'following'),
      ],
    );
  }
}

/// Single stat item (value + label)
class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.grey)),
      ],
    );
  }
}
