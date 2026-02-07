import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest_clone/core/router/route_names.dart';
import 'package:pinterest_clone/core/theme/app_colors.dart';
import 'package:pinterest_clone/core/widgets/shimmer_loading.dart';
import 'package:pinterest_clone/features/boards/domain/entities/board.dart';
import 'package:pinterest_clone/features/home/presentation/providers/home_provider.dart';
import 'package:pinterest_clone/features/pin/presentation/widgets/pin_card.dart';
import 'package:pinterest_clone/features/saved_pins/domain/entities/saved_pin.dart';
import 'package:pinterest_clone/features/saved_pins/presentation/providers/saved_pins_provider.dart';

/// Lazy loading board content - only builds when visited
class LazyBoardContent extends ConsumerStatefulWidget {
  final Board board;
  final int tabIndex;

  const LazyBoardContent({
    super.key,
    required this.board,
    required this.tabIndex,
  });

  @override
  ConsumerState<LazyBoardContent> createState() => LazyBoardContentState();
}

class LazyBoardContentState extends ConsumerState<LazyBoardContent> {
  bool _hasBuilt = false;

  @override
  Widget build(BuildContext context) {
    final visitedTabs = ref.watch(visitedBoardTabsProvider);
    final isVisited = visitedTabs.contains(widget.tabIndex);

    // If not visited yet, show shimmer
    if (!_hasBuilt && !isVisited) {
      return const ShimmerGrid();
    }

    // Mark as built on first real render (persists in provider)
    if (!_hasBuilt) {
      _hasBuilt = true;
      ref.read(visitedBoardTabsProvider.notifier).markVisited(widget.tabIndex);
    }

    final savedPinsState = ref.watch(savedPinsProvider);
    final boardIdeasState = ref.watch(boardIdeasProvider);
    final board = widget.board;

    // Get saved pins for this board
    final savedPinsForBoard =
        savedPinsState.pins.where((sp) => sp.boardId == board.id).toList();

    // Fetch ideas from Pexels
    final moreIdeas = boardIdeasState.getIdeasForBoard(board.id);
    final isLoadingIdeas = boardIdeasState.isLoadingBoard(board.id);

    // Trigger loading if not loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!boardIdeasState.ideasByBoardId.containsKey(board.id) &&
          !boardIdeasState.loadingBoardIds.contains(board.id)) {
        ref
            .read(boardIdeasProvider.notifier)
            .loadIdeasForBoard(board.id, board.name);
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref
            .read(boardIdeasProvider.notifier)
            .loadIdeasForBoard(board.id, board.name);
      },
      color: AppColors.pinterestRed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Board header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          board.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      if (board.isPrivate)
                        const Icon(Icons.lock_outline, color: AppColors.grey),
                    ],
                  ),
                  Text(
                    '${board.pinCount} Pins',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  if (board.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      board.description!,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ],
              ),
            ),
            // Your saves section
            if (savedPinsForBoard.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your saves',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.greyBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal scrollable saved pins
              SizedBox(
                height: 140,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: savedPinsForBoard.length,
                  itemBuilder: (context, index) {
                    final savedPin = savedPinsForBoard[index];
                    return _SavedPinCardFromModel(
                      savedPin: savedPin,
                      onTap: () {
                        context.push(
                          '${RouteNames.pinDetail}/${savedPin.pinId}',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
            // Empty state for boards with no pins
            if (savedPinsForBoard.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pins saved yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save pins to this board to see them here',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // More ideas for this board
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: const Text(
                'More ideas for this board',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            // Masonry grid for more ideas
            if (isLoadingIdeas)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ShimmerGrid(shrinkWrap: true, itemCount: 6),
              )
            else if (moreIdeas.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No ideas found for "${board.name}"',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children:
                      moreIdeas.map((pin) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PinCard(
                            pin: pin,
                            isFullWidth: true,
                            onTap: () {
                              context.push(
                                '${RouteNames.pinDetail}/${pin.id}',
                                extra: pin,
                              );
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Saved pin card from SavedPin (real data from Supabase/Hive)
class _SavedPinCardFromModel extends StatelessWidget {
  final SavedPin savedPin;
  final VoidCallback onTap;

  const _SavedPinCardFromModel({required this.savedPin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: savedPin.imageUrl,
            fit: BoxFit.cover,
            height: 150,
            placeholder:
                (context, url) => Container(color: AppColors.greyLight),
            errorWidget:
                (context, url, error) => Container(
                  color: AppColors.greyLight,
                  child: const Icon(Icons.broken_image),
                ),
          ),
        ),
      ),
    );
  }
}
