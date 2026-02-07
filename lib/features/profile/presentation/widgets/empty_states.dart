import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Empty state for no pins
class NoPinsEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const NoPinsEmptyState({
    super.key,
    this.title = 'No pins yet',
    this.subtitle = 'Tap + to create your first Pin',
    this.icon = Icons.push_pin_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}

/// Empty state for no saved pins
class NoSavedPinsEmptyState extends StatelessWidget {
  const NoSavedPinsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No saved pins yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Save pins to your boards to see them here',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Empty state for no pins in a board
class NoBoardPinsEmptyState extends StatelessWidget {
  const NoBoardPinsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bookmark_border, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'No pins saved to this board',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for no ideas found
class NoIdeasEmptyState extends StatelessWidget {
  final String boardName;

  const NoIdeasEmptyState({super.key, required this.boardName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No ideas found for "$boardName"',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
