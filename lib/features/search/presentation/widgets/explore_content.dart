import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/providers/pin_provider.dart';
import '../../../pin/domain/entities/pin.dart';
import '../../../pin/presentation/widgets/pin_card.dart';
import 'category_card.dart';

/// Explore content with categories and popular pins
class ExploreContent extends ConsumerWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(String name) onCategoryTap;
  final void Function(Pin pin) onPinTap;

  const ExploreContent({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Ideas for you header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Ideas for you',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Categories Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              return CategoryCard(
                name: category['name'],
                icon: category['icon'],
                color: Color(category['color']),
                onTap: () => onCategoryTap(category['name']),
              );
            }, childCount: categories.length),
          ),
        ),
        // Popular ideas header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Popular ideas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Popular pins grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: _PopularPinsGrid(onPinTap: onPinTap),
        ),
      ],
    );
  }
}

/// Popular pins masonry grid
class _PopularPinsGrid extends ConsumerWidget {
  final void Function(Pin pin) onPinTap;

  const _PopularPinsGrid({required this.onPinTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinState = ref.watch(pinProvider);

    if (pinState.feedPins.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childCount: pinState.feedPins.take(10).length,
      itemBuilder: (context, index) {
        final pin = pinState.feedPins[index];
        return PinCard(pin: pin, onTap: () => onPinTap(pin));
      },
    );
  }
}
