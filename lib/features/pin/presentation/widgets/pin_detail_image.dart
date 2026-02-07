import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';

/// Hero image section for pin detail screen
class PinDetailImage extends StatelessWidget {
  final String imageUrl;
  final String pinId;
  final Color avgColor;
  final VoidCallback? onVisualSearchTap;

  const PinDetailImage({
    super.key,
    required this.imageUrl,
    required this.pinId,
    required this.avgColor,
    this.onVisualSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
         child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
         child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder:
                    (context, url) => Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      color: avgColor.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      color: avgColor.withOpacity(0.3),
                      child: const Icon(Icons.broken_image, size: 64),
                    ),
              ),
       ),
       ),

        // Visual search button at bottom right
        if (onVisualSearchTap != null)
          Positioned(
            bottom: 48,
            right: 16,
            child: CircularIconButton(
              icon: Icons.center_focus_strong_outlined,
              backgroundColor: Colors.white.withAlpha(100),
              iconColor: AppColors.black,
              size: 48,
              onTap: onVisualSearchTap!,
            ),
          ),
      ],
    );
  }
}
