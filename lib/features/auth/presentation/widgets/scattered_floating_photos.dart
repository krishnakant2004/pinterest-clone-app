import 'package:flutter/material.dart';

/// Pinterest-style photo collage background for auth screen
/// Matches the real Pinterest app layout exactly
class ScatteredFloatingPhotos extends StatelessWidget {
  const ScatteredFloatingPhotos({super.key});

  // Sample images matching Pinterest auth screen style
  static const List<String> _images = [
    // Top left - interior/home decor
    'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=400',
    // Top right - decorative item
    'https://images.pexels.com/photos/1099816/pexels-photo-1099816.jpeg?auto=compress&cs=tinysrgb&w=400',
    // Center - fashion/outfit (main)
    'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&cs=tinysrgb&w=600',
    // Right - beauty/face
    'https://images.pexels.com/photos/3785079/pexels-photo-3785079.jpeg?auto=compress&cs=tinysrgb&w=400',
    // Left bottom - food
    'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=400',
    // Right bottom - decor
    'https://images.pexels.com/photos/1099680/pexels-photo-1099680.jpeg?auto=compress&cs=tinysrgb&w=400',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final photoHeight =
        size.height * 0.42; // Photos take up about 42% of screen

    return SizedBox(
      height: photoHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top left - interior photo (cut off at left edge)
          Positioned(
            left: -20,
            top: 0,
            child: _PhotoCard(
              imageUrl: _images[0],
              width: size.width * 0.42,
              height: photoHeight * 0.55,
            ),
          ),
          // Top right - decorative item (cut off at top and right)
          Positioned(
            right: -10,
            top: -20,
            child: _PhotoCard(
              imageUrl: _images[1],
              width: size.width * 0.35,
              height: photoHeight * 0.25,
            ),
          ),
          // Center - main fashion photo (largest, prominent)
          Positioned(
            left: size.width * 0.22,
            top: photoHeight * 0.08,
            child: _PhotoCard(
              imageUrl: _images[2],
              width: size.width * 0.56,
              height: photoHeight * 0.85,
              borderRadius: 20,
            ),
          ),
          // Right - beauty/face photo
          Positioned(
            right: 0,
            top: photoHeight * 0.30,
            child: _PhotoCard(
              imageUrl: _images[3],
              width: size.width * 0.35,
              height: photoHeight * 0.40,
            ),
          ),
          // Left bottom - food photo (cut off at left)
          Positioned(
            left: -30,
            top: photoHeight * 0.52,
            child: _PhotoCard(
              imageUrl: _images[4],
              width: size.width * 0.42,
              height: photoHeight * 0.48,
            ),
          ),
          // Right bottom - decor photo (cut off at right)
          Positioned(
            right: -15,
            bottom: -10,
            child: _PhotoCard(
              imageUrl: _images[5],
              width: size.width * 0.38,
              height: photoHeight * 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const _PhotoCard({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Icon(Icons.image, color: Colors.grey[400], size: 40),
            );
          },
        ),
      ),
    );
  }
}
