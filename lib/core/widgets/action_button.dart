import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Reusable action button with icon and label (used for like, comment, etc.)
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isActive;
  final Color? activeColor;
  final double iconSize;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    this.isActive = false,
    this.activeColor,
    this.iconSize = 26,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: isActive ? activeColor : AppColors.black,
          ),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
