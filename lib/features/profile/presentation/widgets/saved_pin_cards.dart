import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Saved pin card for horizontal scroll in board view
class SavedPinCardHorizontal extends StatelessWidget {
  final dynamic savedPin;
  final VoidCallback onTap;

  const SavedPinCardHorizontal({
    super.key,
    required this.savedPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: savedPin.imageUrl ?? '',
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(color: AppColors.greyLight),
            errorWidget:
                (context, url, error) => Container(
                  color: AppColors.greyLight,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppColors.grey,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

/// Saved pin card for masonry grid in All Pins view
class SavedPinCardProfile extends StatelessWidget {
  final dynamic savedPin;
  final VoidCallback onTap;

  const SavedPinCardProfile({
    super.key,
    required this.savedPin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Random height for masonry effect
    final heights = [180.0, 220.0, 200.0, 250.0, 190.0];
    final height = heights[savedPin.hashCode.abs() % heights.length];

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: savedPin.imageUrl ?? '',
          height: height,
          fit: BoxFit.cover,
          placeholder:
              (context, url) =>
                  Container(height: height, color: AppColors.greyLight),
          errorWidget:
              (context, url, error) => Container(
                height: height,
                color: AppColors.greyLight,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.grey,
                ),
              ),
        ),
      ),
    );
  }
}
