import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shows the more options bottom sheet for board
void showBoardMoreOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit board'),
              onTap: () {
                Navigator.pop(context);
                // Edit board
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                // Archive board
              },
            ),
            ListTile(
              leading: const Icon(Icons.merge_outlined),
              title: const Text('Merge'),
              onTap: () {
                Navigator.pop(context);
                // Merge board
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.pinterestRed,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: AppColors.pinterestRed),
              ),
              onTap: () {
                Navigator.pop(context);
                // Delete board
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

/// Shows the filter options bottom sheet
void showFilterOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Custom'),
              trailing: const Icon(Icons.check, color: AppColors.black),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('A to Z'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Last saved to'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

/// Shows the add options bottom sheet
void showAddOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Save from URL'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

/// Common bottom sheet handle widget
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
