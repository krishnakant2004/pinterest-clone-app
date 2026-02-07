import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

/// Profile avatar in app bar (small, tappable)
class ProfileAppBarAvatar extends StatelessWidget {
  final ProfileState profile;

  const ProfileAppBarAvatar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(RouteNames.settings);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF9B59B6),
        backgroundImage:
            profile.avatarUrl != null
                ? CachedNetworkImageProvider(profile.avatarUrl!)
                : null,
        child:
            profile.avatarUrl == null
                ? Text(
                  profile.displayName?.isNotEmpty == true
                      ? profile.displayName![0].toUpperCase()
                      : 'K',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                )
                : null,
      ),
    );
  }
}

/// Profile tab bar (Pins | Boards | Collages)
class ProfileTabBar extends StatelessWidget {
  final TabController tabController;
  final ValueChanged<int> onTabChanged;

  const ProfileTabBar({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      onTap: onTabChanged,
      labelColor: AppColors.black,
      unselectedLabelColor: AppColors.grey,
      indicatorColor: AppColors.black,
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(text: 'Pins'),
        Tab(text: 'Boards'),
        Tab(text: 'Collages'),
      ],
    );
  }
}

/// Search bar with add button
class ProfileSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddTap;

  const ProfileSearchBar({
    super.key,
    required this.controller,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search your Pins',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.greyBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.black, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
