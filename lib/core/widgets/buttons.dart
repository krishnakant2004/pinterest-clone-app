import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Pinterest-style primary button (Save, Follow, etc.)
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSmall;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isSmall = false,
    this.isOutlined = false,
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
          horizontal: isSmall ? 16 : 24,
          vertical: isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color:
              isOutlined
                  ? Colors.transparent
                  : (backgroundColor ?? AppColors.pinterestRed),
          borderRadius: BorderRadius.circular(24),
          border:
              isOutlined
                  ? Border.all(
                    color: backgroundColor ?? AppColors.black,
                    width: 1.5,
                  )
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.bold,
            color:
                isOutlined
                    ? (backgroundColor ?? AppColors.black)
                    : (textColor ?? Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Follow/Following toggle button
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback onTap;
  final bool isSmall;

  const FollowButton({
    super.key,
    required this.isFollowing,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: isFollowing ? 'Following' : 'Follow',
      onTap: onTap,
      backgroundColor:
          isFollowing ? AppColors.greyBackground : AppColors.pinterestRed,
      textColor: isFollowing ? AppColors.black : Colors.white,
      isSmall: isSmall,
    );
  }
}

/// Save/Saved toggle button
class SaveButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onTap;

  const SaveButton({super.key, required this.isSaved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: isSaved ? 'Saved' : 'Save',
      onTap: onTap,
      backgroundColor: isSaved ? AppColors.black : AppColors.pinterestRed,
    );
  }
}
