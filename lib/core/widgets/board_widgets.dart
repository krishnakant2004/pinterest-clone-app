import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/boards/domain/entities/board.dart';
import '../theme/app_colors.dart';
import 'bottom_sheet_widgets.dart';

/// Board list item widget
class BoardListItem extends StatelessWidget {
  final Board board;
  final bool isSelected;
  final VoidCallback onTap;

  const BoardListItem({
    super.key,
    required this.board,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BoardThumbnail(imageUrl: board.coverImageUrl, size: 48),
      title: Text(
        board.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${board.pinCount} pins',
        style: const TextStyle(color: AppColors.grey, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (board.isPrivate)
            const Icon(Icons.lock_outline, size: 16, color: AppColors.grey),
          if (isSelected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check, color: AppColors.pinterestRed),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Board thumbnail widget
class BoardThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const BoardThumbnail({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: imageUrl != null ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
        image:
            imageUrl != null
                ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl!),
                  fit: BoxFit.cover,
                )
                : null,
      ),
    );
  }
}

/// Create board list tile
class CreateBoardTile extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateBoardTile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, color: AppColors.black),
      ),
      title: const Text(
        'Create board',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap ?? () => context.push('/create-board'),
    );
  }
}

/// Board selector bottom sheet
class BoardSelectorBottomSheet extends ConsumerWidget {
  final String title;
  final List<Board> boards;
  final String? selectedBoardId;
  final Function(Board board) onBoardSelected;
  final VoidCallback? onCreateBoard;

  const BoardSelectorBottomSheet({
    super.key,
    this.title = 'Select board',
    required this.boards,
    this.selectedBoardId,
    required this.onBoardSelected,
    this.onCreateBoard,
  });

  static Future<Board?> show({
    required BuildContext context,
    required List<Board> boards,
    String? selectedBoardId,
    String title = 'Select board',
  }) async {
    return showAppBottomSheet<Board>(
      context: context,
      child: BoardSelectorBottomSheet(
        title: title,
        boards: boards,
        selectedBoardId: selectedBoardId,
        onBoardSelected: (board) => Navigator.pop(context, board),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetTitle(title: title),
          CreateBoardTile(onTap: onCreateBoard),
          const Divider(),
          if (boards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No boards yet. Create your first board!',
                style: TextStyle(color: AppColors.grey),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  final board = boards[index];
                  return BoardListItem(
                    board: board,
                    isSelected: board.id == selectedBoardId,
                    onTap: () => onBoardSelected(board),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
