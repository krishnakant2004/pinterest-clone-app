import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Action button for bottom action bar
class BoardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BoardActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.black),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom action bar for board detail screen
class BoardBottomActionBar extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onOrganiseTap;
  final VoidCallback onAddTap;
  final VoidCallback onMoreIdeasTap;

  const BoardBottomActionBar({
    super.key,
    required this.tabController,
    required this.onOrganiseTap,
    required this.onAddTap,
    required this.onMoreIdeasTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        final isAllSavesTab = tabController.index == 1;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 8,
            top: 8,
          ),
          color: AppColors.white.withAlpha(150),
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(150),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAllSavesTab) ...[
                      BoardActionButton(
                        icon: Icons.auto_fix_high_outlined,
                        label: 'Organise',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onOrganiseTap();
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    BoardActionButton(
                      icon: Icons.add,
                      label: 'Add',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onAddTap();
                      },
                    ),
                    const SizedBox(width: 8),
                    BoardActionButton(
                      icon: Icons.auto_awesome_outlined,
                      label: 'More ideas',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onMoreIdeasTap();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
