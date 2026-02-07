import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Create Pin'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Publish pin
            },
            child: const Text(
              'Publish',
              style: TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Picker
            GestureDetector(
              onTap: () {
                // TODO: Pick image
              },
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.greyLight,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_outlined,
                        size: 32,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Click to upload',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'or drag and drop',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title Field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Add a title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            // Description Field
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell everyone what your Pin is about',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.grey),
              ),
            ),
            const Divider(),
            // Link Field
            const TextField(
              decoration: InputDecoration(
                hintText: 'Add a destination link',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.grey),
                prefixIcon: Icon(Icons.link, color: AppColors.grey),
              ),
            ),
            const Divider(),
            // Board Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.dashboard_outlined,
                  color: AppColors.grey,
                ),
              ),
              title: const Text('Choose board'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Select board
              },
            ),
          ],
        ),
      ),
    );
  }
}
