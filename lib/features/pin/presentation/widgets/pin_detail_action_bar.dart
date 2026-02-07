import 'package:flutter/material.dart';

import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/buttons.dart';

/// Action bar for pin detail (like, comment, share, more, save)
class PinDetailActionBar extends StatelessWidget {
  final bool isLiked;
  final bool isSaved;
  final String likeCount;
  final String commentCount;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback onMoreTap;
  final VoidCallback onSaveTap;

  const PinDetailActionBar({
    super.key,
    required this.isLiked,
    required this.isSaved,
    this.likeCount = '0',
    this.commentCount = '0',
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onMoreTap,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Like button with count
          ActionButton(
            icon:
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
            label: likeCount,
            isActive: isLiked,
            activeColor: Colors.red,
            onTap: onLikeTap,
          ),
          const SizedBox(width: 12),
          // Comment button with count
          ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: commentCount,
            onTap: onCommentTap,
          ),
          const SizedBox(width: 12),
          // Share button
          ActionButton(icon: Icons.share_outlined, onTap: onShareTap),
          const SizedBox(width: 12),
          // More options (three dots)
          ActionButton(icon: Icons.more_horiz, onTap: onMoreTap),
          const Spacer(),
          // Save button
          SaveButton(isSaved: isSaved, onTap: onSaveTap),
        ],
      ),
    );
  }
}
