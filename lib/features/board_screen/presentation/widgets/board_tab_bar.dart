import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Tab bar persistent header delegate for Board detail screen
class BoardTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final VoidCallback? onFilterTap;

  BoardTabBarDelegate({required this.tabController, this.onFilterTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.black,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.black,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [Tab(text: 'More ideas'), Tab(text: 'All saves')],
            ),
          ),
          // Filter icon (only shown in All saves tab)
          AnimatedBuilder(
            animation: tabController,
            builder: (context, child) {
              if (tabController.index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: onFilterTap,
                    icon: const Icon(Icons.tune, color: AppColors.black),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant BoardTabBarDelegate oldDelegate) {
    return tabController != oldDelegate.tabController;
  }
}
