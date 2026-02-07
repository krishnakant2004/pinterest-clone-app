import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../../saved_pins/domain/entities/saved_pin.dart';
import '../../../saved_pins/presentation/providers/saved_pins_provider.dart';
import 'filter_chips.dart';

/// Pins tab content with filter chips and grid
class PinsTabContent extends ConsumerWidget {
  final SavedPinsState savedPinsState;
  final String filter;
  final ValueChanged<String> onFilterChanged;

  const PinsTabContent({
    super.key,
    required this.savedPinsState,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Filter chips
        PinsFilterChips(
          selectedFilter: filter,
          onFilterChanged: onFilterChanged,
        ),
        // Pins grid
        Expanded(child: _buildPinsGrid(context)),
        // Pins count
        if (savedPinsState.pins.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '${savedPinsState.pins.length} Pins saved',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPinsGrid(BuildContext context) {
    if (savedPinsState.isLoading && savedPinsState.pins.isEmpty) {
      return const ShimmerGrid(shrinkWrap: false);
    }

    if (savedPinsState.pins.isEmpty) {
      return const EmptyPinsState();
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: savedPinsState.pins.length,
      itemBuilder: (context, index) {
        final savedPin = savedPinsState.pins[index];
        return SavedPinCard(
          savedPin: savedPin,
          onTap: () => _navigateToPinDetail(context, savedPin),
        );
      },
    );
  }

  void _navigateToPinDetail(BuildContext context, SavedPin savedPin) {
    final pin = Pin(
      id: savedPin.pinId,
      imageUrl: savedPin.imageUrl,
      thumbnailUrl: savedPin.thumbnailUrl,
      width: savedPin.width,
      height: savedPin.height,
      title: savedPin.title,
      description: savedPin.description,
      photographer: savedPin.photographer,
      avgColor: savedPin.avgColor,
      link: savedPin.link,
    );
    context.push('${RouteNames.pinDetail}/${savedPin.pinId}', extra: pin);
  }
}

/// Filter chips for pins tab
class PinsFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const PinsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ProfileFilterChip(
            icon: Icons.grid_view,
            isSelected: true,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          ProfileFilterChip(
            label: 'Favourites',
            icon: Icons.star,
            isSelected: selectedFilter == 'favourites',
            onTap:
                () => onFilterChanged(
                  selectedFilter == 'favourites' ? 'all' : 'favourites',
                ),
          ),
          const SizedBox(width: 8),
          ProfileFilterChip(
            label: 'Created by you',
            isSelected: selectedFilter == 'created',
            onTap:
                () => onFilterChanged(
                  selectedFilter == 'created' ? 'all' : 'created',
                ),
          ),
        ],
      ),
    );
  }
}

/// Empty state for pins tab
class EmptyPinsState extends StatelessWidget {
  const EmptyPinsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.push_pin_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No saved pins yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Save pins to see them here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Saved pin card for grid
class SavedPinCard extends StatelessWidget {
  final SavedPin savedPin;
  final VoidCallback onTap;

  const SavedPinCard({super.key, required this.savedPin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final heights = [140.0, 180.0, 160.0, 200.0, 150.0];
    final height = heights[savedPin.hashCode.abs() % heights.length];

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: savedPin.imageUrl,
          height: height,
          fit: BoxFit.cover,
          placeholder:
              (_, __) => Container(height: height, color: AppColors.greyLight),
          errorWidget:
              (_, __, ___) => Container(
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
