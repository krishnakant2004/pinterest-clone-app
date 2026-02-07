import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Collapsible board info header
class BoardInfoHeader extends StatelessWidget {
  final String boardName;
  final int pinCount;
  final bool isVisible;

  const BoardInfoHeader({
    super.key,
    required this.boardName,
    required this.pinCount,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isVisible ? 1 : 0,
        child:
            isVisible
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boardName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$pinCount Pins',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
