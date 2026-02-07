import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../boards/domain/entities/board.dart';
import '../../../boards/presentation/providers/boards_provider.dart';
import '../../../saved_pins/domain/entities/saved_pin.dart';
import '../../../saved_pins/presentation/providers/saved_pins_provider.dart';
import 'filter_chips.dart';

/// Board colors for placeholders
const _boardColors = [
  Color(0xFF9B59B6),
  Color(0xFF3498DB),
  Color(0xFFE91E63),
  Color(0xFFFF9800),
  Color(0xFF2ECC71),
  Color(0xFF1ABC9C),
  Color(0xFFE74C3C),
  Color(0xFF9C27B0),
];

/// Boards tab content with filter chips and grid
class BoardsTabContent extends ConsumerWidget {
  final String sortBy;
  final bool showGroup;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onGroupToggle;
  final SavedPinsState savedPinsState;

  const BoardsTabContent({
    super.key,
    required this.sortBy,
    required this.showGroup,
    required this.onSortChanged,
    required this.onGroupToggle,
    required this.savedPinsState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsState = ref.watch(boardsProvider);
    final boards = boardsState.boards;

    return CustomScrollView(
      slivers: [
        // Filter chips
        SliverToBoxAdapter(
          child: BoardsFilterChips(
            sortBy: sortBy,
            showGroup: showGroup,
            onSortChanged: onSortChanged,
            onGroupToggle: onGroupToggle,
          ),
        ),
        // Boards grid
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver:
              boards.isEmpty
                  ? SliverToBoxAdapter(
                    child: EmptyBoardsState(
                      onCreateTap: () => context.push(RouteNames.createBoard),
                    ),
                  )
                  : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final board = boards[index];
                      final boardPins =
                          savedPinsState.pins
                              .where((p) => p.boardId == board.id)
                              .take(3)
                              .toList();
                      return BoardCardWithPins(
                        board: board,
                        coverPins: boardPins,
                        onTap: () {
                          context.push('${RouteNames.boardDetail}/${board.id}');
                        },
                      );
                    }, childCount: boards.length),
                  ),
        ),
        // Unorganised ideas section
        if (savedPinsState.pins.isNotEmpty)
          SliverToBoxAdapter(
            child: UnorganisedIdeasSection(
              pins: savedPinsState.pins.take(10).toList(),
              onOrganiseTap: () {
                // TODO: Navigate to organise screen
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

/// Filter chips for boards tab
class BoardsFilterChips extends StatelessWidget {
  final String sortBy;
  final bool showGroup;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onGroupToggle;

  const BoardsFilterChips({
    super.key,
    required this.sortBy,
    required this.showGroup,
    required this.onSortChanged,
    required this.onGroupToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SortDropdownChip(sortBy: sortBy, onSortChanged: onSortChanged),
          const SizedBox(width: 8),
          ProfileFilterChip(
            label: 'Group',
            isSelected: showGroup,
            onTap: onGroupToggle,
          ),
        ],
      ),
    );
  }
}

/// Board card with cover pins layout (3-image layout)
class BoardCardWithPins extends StatelessWidget {
  final Board board;
  final List<SavedPin> coverPins;
  final VoidCallback onTap;

  const BoardCardWithPins({
    super.key,
    required this.board,
    required this.coverPins,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BoardCoverLayout(
                coverPins: coverPins,
                boardName: board.name,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  board.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (board.isPrivate)
                const Icon(Icons.lock_outline, size: 14, color: AppColors.grey),
            ],
          ),
          Text(
            '${board.pinCount} Pins',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Pinterest-style 3-image board cover layout
class BoardCoverLayout extends StatelessWidget {
  final List<SavedPin> coverPins;
  final String boardName;

  const BoardCoverLayout({
    super.key,
    required this.coverPins,
    required this.boardName,
  });

  @override
  Widget build(BuildContext context) {
    final colorIndex = boardName.hashCode.abs() % _boardColors.length;
    final placeholderColor = _boardColors[colorIndex].withOpacity(0.15);

    if (coverPins.isEmpty) {
      return _buildEmptyLayout(placeholderColor);
    }

    return _buildPinsLayout(placeholderColor);
  }

  Widget _buildEmptyLayout(Color color) {
    return Container(
      color: color,
      child: Row(
        children: [
          Expanded(flex: 2, child: Container(color: color)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: Container(color: color)),
                const SizedBox(height: 2),
                Expanded(child: Container(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinsLayout(Color placeholderColor) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child:
              coverPins.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: coverPins[0].imageUrl,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    placeholder: (_, __) => Container(color: placeholderColor),
                    errorWidget:
                        (_, __, ___) => Container(color: placeholderColor),
                  )
                  : Container(color: placeholderColor),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child:
                    coverPins.length > 1
                        ? CachedNetworkImage(
                          imageUrl: coverPins[1].imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (_, __) => Container(color: placeholderColor),
                          errorWidget:
                              (_, __, ___) =>
                                  Container(color: placeholderColor),
                        )
                        : Container(color: placeholderColor),
              ),
              const SizedBox(height: 2),
              Expanded(
                child:
                    coverPins.length > 2
                        ? CachedNetworkImage(
                          imageUrl: coverPins[2].imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (_, __) => Container(color: placeholderColor),
                          errorWidget:
                              (_, __, ___) =>
                                  Container(color: placeholderColor),
                        )
                        : Container(color: placeholderColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Unorganised ideas horizontal section
class UnorganisedIdeasSection extends StatelessWidget {
  final List<SavedPin> pins;
  final VoidCallback onOrganiseTap;

  const UnorganisedIdeasSection({
    super.key,
    required this.pins,
    required this.onOrganiseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unorganised ideas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onOrganiseTap,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.greyBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Organise',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: pins.length,
            itemBuilder: (context, index) {
              final pin = pins[index];
              return Container(
                width: 110,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: pin.imageUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (_, __) => Container(color: AppColors.greyLight),
                    errorWidget:
                        (_, __, ___) => Container(color: AppColors.greyLight),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Empty state for boards tab
class EmptyBoardsState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const EmptyBoardsState({super.key, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No boards yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first board',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onCreateTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinterestRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Create board'),
          ),
        ],
      ),
    );
  }
}
