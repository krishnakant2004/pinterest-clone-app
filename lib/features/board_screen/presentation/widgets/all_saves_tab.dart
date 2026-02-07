import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../saved_pins/domain/entities/saved_pin.dart';
import 'board_pin_cards.dart';

/// All Saves tab content with masonry grid
class AllSavesTab extends StatelessWidget {
  final List<SavedPin> pins;
  final Function(SavedPin) onPinTap;

  const AllSavesTab({super.key, required this.pins, required this.onPinTap});

  @override
  Widget build(BuildContext context) {
    if (pins.isEmpty) {
      return const EmptyAllSavesState();
    }

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: pins.length,
      itemBuilder: (context, index) {
        final pin = pins[index];
        return BoardSavedPinCard(pin: pin, onTap: () => onPinTap(pin));
      },
    );
  }
}

/// Empty state for All Saves tab
class EmptyAllSavesState extends StatelessWidget {
  const EmptyAllSavesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.push_pin_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Pins yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Pins to your board',
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
