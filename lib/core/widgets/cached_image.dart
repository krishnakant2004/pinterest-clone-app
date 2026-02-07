import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            (context, url) =>
                placeholder ??
                Shimmer.fromColors(
                  baseColor: AppColors.greyLight,
                  highlightColor: AppColors.white,
                  child: Container(
                    width: width,
                    height: height,
                    color: AppColors.greyLight,
                  ),
                ),
        errorWidget:
            (context, url, error) =>
                errorWidget ??
                Container(
                  width: width,
                  height: height,
                  color: AppColors.greyLight,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.grey,
                  ),
                ),
      ),
    );
  }
}
