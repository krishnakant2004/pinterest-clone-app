import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Reusable filter chip for profile tabs
class ProfileFilterChip extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ProfileFilterChip({
    super.key,
    this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.greyBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.white : AppColors.black,
              ),
              if (label != null) const SizedBox(width: 6),
            ],
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sort dropdown chip for boards tab
class SortDropdownChip extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const SortDropdownChip({
    super.key,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: 'custom', child: Text('Custom')),
            const PopupMenuItem(value: 'a-z', child: Text('A to Z')),
            const PopupMenuItem(
              value: 'last-saved',
              child: Text('Last saved to'),
            ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, color: AppColors.white, size: 18),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: AppColors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
