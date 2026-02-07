import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../boards/domain/entities/board.dart';
import '../../../../core/theme/app_colors.dart';

/// Board color palette for boards without cover images
const boardColors = [
  Color(0xFF9B59B6),
  Color(0xFF3498DB),
  Color(0xFFE91E63),
  Color(0xFFFF9800),
  Color(0xFF2ECC71),
  Color(0xFF1ABC9C),
  Color(0xFFE74C3C),
  Color(0xFF9C27B0),
];

/// Board card using real Board from Supabase/Hive
class BoardCard extends StatelessWidget {
  final Board board;
  final VoidCallback onTap;

  const BoardCard({super.key, required this.board, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Generate a color based on board name
    final colorIndex = board.name.hashCode.abs() % boardColors.length;
    final color = boardColors[colorIndex];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    board.coverImageUrl != null
                        ? null
                        : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                image:
                    board.coverImageUrl != null
                        ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            board.coverImageUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  board.coverImageUrl == null
                      ? Center(
                        child: Icon(
                          Icons.dashboard_outlined,
                          size: 48,
                          color: color,
                        ),
                      )
                      : null,
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
            style: const TextStyle(color: AppColors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Create board card with + icon
class CreateBoardCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreateBoardCard({super.key, required this.onTap});

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
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.add, size: 48, color: AppColors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create board',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
