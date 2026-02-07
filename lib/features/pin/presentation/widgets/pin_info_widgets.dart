import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/user_widgets.dart';

/// Photographer/user info row for pin detail
class PinPhotographerRow extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const PinPhotographerRow({super.key, required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: UserRow(name: name, imageUrl: avatarUrl),
    );
  }
}

/// Comment preview row for pin detail
class PinCommentPreview extends StatelessWidget {
  final String? comment;
  final VoidCallback onTap;

  const PinCommentPreview({super.key, this.comment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: AppColors.black),
            children: [
              TextSpan(text: comment ?? '"Love it! ❤️ Loveit" ... '),
              TextSpan(
                text: 'View all comments',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
