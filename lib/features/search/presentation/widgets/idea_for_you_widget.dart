import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pinterest_clone/core/widgets/shimmer_loading.dart';
import 'package:pinterest_clone/features/pin/data/models/pin_model.dart';
import 'package:pinterest_clone/features/pin/domain/entities/pin.dart';

class PinterestCardSection extends StatelessWidget {
  final String sectionTitle;
  final Future<List<Pin>> pins;
  final VoidCallback? onSearchTap;

  const PinterestCardSection({
    Key? key,
    required this.sectionTitle,
    required this.pins,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Search Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Popular on Pinterest',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sectionTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
      
            // FutureBuilder for Pins
            FutureBuilder<List<Pin>>(
              future: pins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoader();
                }
      
                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }
      
                final pinList = snapshot.data ?? [];
      
                // Validate that we have at least 5 pins
                if (pinList.length < 5) {
                  return _buildInsufficientPinsWidget(pinList.length);
                }
      
                return _buildHorizontalPinList(pinList);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Expanded(child: ShimmerLoading()),
            const SizedBox(width: 2),
            Expanded(child: ShimmerLoading()),
            const SizedBox(width: 2),
            Expanded(child: ShimmerLoading()),
            const SizedBox(width: 2),
            Expanded(child: ShimmerLoading()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 12),
              Text(
                'Error loading pins',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: TextStyle(fontSize: 14, color: Colors.red[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsufficientPinsWidget(int count) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.orange[300],
              ),
              const SizedBox(height: 12),
              Text(
                'Not enough pins',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Found $count pins, need at least 5',
                style: TextStyle(fontSize: 14, color: Colors.orange[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalPinList(List<Pin> pins) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Expanded(child: _buildCard(pins[0], 16, 0, 16, 0)),
            const SizedBox(width: 2),
            Expanded(child: _buildCard(pins[1], 0, 0, 0, 0)),
            const SizedBox(width: 2),
            Expanded(child: _buildCard(pins[3], 0, 0, 0, 0)),
            const SizedBox(width: 2),
            Expanded(child: _buildCard(pins[4], 0, 16, 0, 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Pin card, int tl, int tr, int bl, int br) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(tl.toDouble()),
        topRight: Radius.circular(tr.toDouble()),
        bottomLeft: Radius.circular(bl.toDouble()),
        bottomRight: Radius.circular(br.toDouble()),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with error handling
            Image.network(
              card.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return ShimmerLoading();
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
