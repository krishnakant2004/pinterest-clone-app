import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Model for collage data
class Collage {
  final String id;
  final String title;
  final List<String> imageUrls;
  final DateTime createdAt;

  const Collage({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.createdAt,
  });
}

/// Collages tab content with grid
class CollagesTabContent extends StatelessWidget {
  final List<Collage> collages;
  final VoidCallback onCreateTap;
  final ValueChanged<Collage> onCollageTap;

  const CollagesTabContent({
    super.key,
    required this.collages,
    required this.onCreateTap,
    required this.onCollageTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0) {
                return CreateCollageCard(onTap: onCreateTap);
              }
              if (collages.isEmpty) return null;
              final collage = collages[index - 1];
              return CollageCard(
                collage: collage,
                onTap: () => onCollageTap(collage),
              );
            }, childCount: collages.length + 1),
          ),
        ),
        if (collages.isEmpty)
          const SliverToBoxAdapter(child: EmptyCollagesState()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

/// Create collage card with dashed border
class CreateCollageCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateCollageCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: Colors.grey[400]!,
                strokeWidth: 2,
                dashWidth: 8,
                dashSpace: 4,
                borderRadius: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create collage',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            'Combine Pins',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Collage card with preview images
class CollageCard extends StatelessWidget {
  final Collage collage;
  final VoidCallback onTap;

  const CollageCard({super.key, required this.collage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildCollagePreview(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            collage.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${collage.imageUrls.length} Pins',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCollagePreview() {
    if (collage.imageUrls.isEmpty) {
      return Container(
        color: AppColors.greyBackground,
        child: const Center(
          child: Icon(Icons.photo_library_outlined, color: AppColors.grey),
        ),
      );
    }

    // 2x2 grid preview
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index < collage.imageUrls.length) {
          return CachedNetworkImage(
            imageUrl: collage.imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.greyLight),
            errorWidget: (_, __, ___) => Container(color: AppColors.greyLight),
          );
        }
        return Container(color: AppColors.greyLight);
      },
    );
  }
}

/// Dashed border painter for create collage card
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 8,
    this.dashSpace = 4,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final length = dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

/// Empty state for collages
class EmptyCollagesState extends StatelessWidget {
  const EmptyCollagesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No collages yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create collages by combining your saved Pins',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
