import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../pin/domain/entities/pin.dart';
import 'board_pin_cards.dart';

/// More Ideas tab content with masonry grid
class MoreIdeasTab extends StatelessWidget {
  final List<Pin> pins;
  final bool isLoading;
  final Function(Pin) onPinTap;

  const MoreIdeasTab({
    super.key,
    required this.pins,
    required this.isLoading,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pinterestRed),
      );
    }

    if (pins.isEmpty) {
      return const EmptyMoreIdeasState();
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: pins.length,
      itemBuilder: (context, index) {
        final pin = pins[index];
        return BoardPinCard(
          pin: pin,
          onTap: () => onPinTap(pin),
          showPinIcon: true,
        );
      },
    );
  }
}

/// Empty state for More Ideas tab
class EmptyMoreIdeasState extends StatelessWidget {
  const EmptyMoreIdeasState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No ideas found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll find more ideas for you soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
