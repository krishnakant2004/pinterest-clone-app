import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pin.dart';
import 'pin_card.dart';

/// Related pins grid for pin detail screen
class RelatedPinsGrid extends StatelessWidget {
  final List<Pin> pins;
  final bool isLoading;
  final Function(Pin pin) onPinTap;

  const RelatedPinsGrid({
    super.key,
    required this.pins,
    this.isLoading = false,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (pins.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No related pins found',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MasonryGridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: pins.length,
        itemBuilder: (context, index) {
          final pin = pins[index];
          return PinCard(pin: pin, onTap: () => onPinTap(pin));
        },
      ),
    );
  }
}

/// Section header for "More to explore"
class MoreToExploreHeader extends StatelessWidget {
  const MoreToExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        'More to explore',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }
}
