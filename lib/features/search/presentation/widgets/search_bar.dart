import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Search bar with back button and camera icon
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showBackButton;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onCameraPressed;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showBackButton,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search for ideas',
    this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(onPressed: onClear, icon: const Icon(Icons.arrow_back)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  suffixIcon:
                      controller.text.isNotEmpty
                          ? IconButton(
                            onPressed: onClear,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.grey,
                            ),
                          )
                          : IconButton(
                            onPressed: onCameraPressed,
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.grey,
                            ),
                          ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search text field without the row wrapper
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search for ideas',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close, color: AppColors.grey),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
