import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../pin/domain/entities/pin.dart';
import '../../../pin/presentation/widgets/pin_card.dart';

/// Search results masonry grid with pull-to-refresh
class SearchResultsGrid extends StatelessWidget {
  final List<Pin> results;
  final String query;
  final Future<void> Function() onRefresh;
  final void Function(Pin pin) onPinTap;

  const SearchResultsGrid({
    super.key,
    required this.results,
    required this.query,
    required this.onRefresh,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final pin = results[index];
          return PinCard(pin: pin, onTap: () => onPinTap(pin));
        },
      ),
    );
  }
}
