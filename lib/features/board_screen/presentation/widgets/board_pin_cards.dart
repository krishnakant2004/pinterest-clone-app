import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../../saved_pins/domain/entities/saved_pin.dart';

/// Pin card with overlay actions for More Ideas tab
class BoardPinCard extends StatelessWidget {
  final Pin pin;
  final VoidCallback onTap;
  final bool showPinIcon;
  final bool showFavoriteIcon;

  const BoardPinCard({
    super.key,
    required this.pin,
    required this.onTap,
    this.showPinIcon = false,
    this.showFavoriteIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pin Image with overlay
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  pin.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.grey.withOpacity(0.2),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    );
                  },
                ),
              ),
              // Pin icon (for More ideas tab)
              if (showPinIcon)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.push_pin,
                      size: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
              // Favorite icon (for All saves tab)
              if (showFavoriteIcon)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(
                    Icons.star_border,
                    size: 24,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
            ],
          ),
        ),
      
      ],
    );
  }
}

/// Saved pin card for All Saves tab
class BoardSavedPinCard extends StatelessWidget {
  final SavedPin pin;
  final VoidCallback onTap;

  const BoardSavedPinCard({super.key, required this.pin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pin Image with overlay
        GestureDetector(
          onTap: onTap,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  pin.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: AppColors.grey.withOpacity(0.2),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    );
                  },
                ),
              ),
              // Favorite icon
              Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  Icons.star_border,
                  size: 24,
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      
      ],
    );
  }
}
