import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/pin_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../pin/presentation/widgets/pin_card.dart';

/// For You feed - main masonry grid
class ForYouFeed extends ConsumerStatefulWidget {
  const ForYouFeed({super.key});

  @override
  ConsumerState<ForYouFeed> createState() => _ForYouFeedState();
}

class _ForYouFeedState extends ConsumerState<ForYouFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(pinProvider.notifier).loadMoreFeedPins();
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await ref.read(pinProvider.notifier).refreshFeedPins();
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinProvider);

    if (pinState.isFeedLoading && pinState.feedPins.isEmpty) {
      return const ShimmerGrid();
    }

    if (pinState.error != null && pinState.feedPins.isEmpty) {
      return _buildErrorState(pinState.error!);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.pinterestRed,
      child: MasonryGridView.count(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount:
            pinState.feedPins.length + (pinState.isFeedLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= pinState.feedPins.length) {
            return ShimmerPinCard(height: index.isEven ? 200 : 250);
          }

          final pin = pinState.feedPins[index];
          return PinCard(
            pin: pin,
            onTap: () {
              context.push('${RouteNames.pinDetail}/${pin.id}', extra: pin);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(pinProvider.notifier).loadFeedPins();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
