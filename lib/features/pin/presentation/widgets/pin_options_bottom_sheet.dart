import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pin.dart';

/// Bottom sheet with pin options (Save, Share, Download, etc.)
class PinOptionsBottomSheet extends StatelessWidget {
  final Pin pin;
  final String? boardName; // Board that inspired this pin
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onSeeMoreLikeThis;
  final VoidCallback? onSeeLessLikeThis;
  final VoidCallback? onStopSeeingPins;
  final VoidCallback? onReport;

  const PinOptionsBottomSheet({
    super.key,
    required this.pin,
    this.boardName,
    this.onSave,
    this.onShare,
    this.onDownload,
    this.onSeeMoreLikeThis,
    this.onSeeLessLikeThis,
    this.onStopSeeingPins,
    this.onReport,
  });

  /// Show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Pin pin,
    String? boardName,
    VoidCallback? onSave,
    VoidCallback? onShare,
    VoidCallback? onDownload,
    VoidCallback? onSeeMoreLikeThis,
    VoidCallback? onSeeLessLikeThis,
    VoidCallback? onStopSeeingPins,
    VoidCallback? onReport,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => PinOptionsBottomSheet(
            pin: pin,
            boardName: boardName,
            onSave: onSave,
            onShare: onShare,
            onDownload: onDownload,
            onSeeMoreLikeThis: onSeeMoreLikeThis,
            onSeeLessLikeThis: onSeeLessLikeThis,
            onStopSeeingPins: onStopSeeingPins,
            onReport: onReport,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avgColor =
        pin.avgColor != null
            ? Color(int.parse(pin.avgColor!.replaceFirst('#', '0xFF')))
            : AppColors.greyLight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Close button and Pin preview
            Stack(
              alignment: Alignment.center,
              children: [
                // Close button on left
                Positioned(
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 28,
                      color: AppColors.black,
                    ),
                  ),
                ),

                // Pin thumbnail in center
                Container(
                  width: 100,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: avgColor.withOpacity(0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: pin.thumbnailUrl ?? pin.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Container(color: avgColor.withOpacity(0.3)),
                      errorWidget:
                          (context, url, error) => Container(
                            color: avgColor.withOpacity(0.3),
                            child: const Icon(Icons.broken_image),
                          ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Board inspiration text
            if (boardName != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    children: [
                      const TextSpan(
                        text: 'This Pin is inspired by your board ',
                      ),
                      TextSpan(
                        text: boardName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Options list
            _OptionTile(
              icon: Icons.push_pin_outlined,
              label: 'Save',
              onTap: () {
                Navigator.pop(context);
                onSave?.call();
              },
            ),
            _OptionTile(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _OptionTile(
              icon: Icons.download_outlined,
              label: 'Download image',
              onTap: () {
                Navigator.pop(context);
                onDownload?.call();
              },
            ),
            _OptionTile(
              icon: Icons.favorite_border,
              label: 'See more like this',
              onTap: () {
                Navigator.pop(context);
                onSeeMoreLikeThis?.call();
              },
            ),
            _OptionTile(
              icon: Icons.visibility_off_outlined,
              label: 'See less like this',
              onTap: () {
                Navigator.pop(context);
                onSeeLessLikeThis?.call();
              },
            ),
            if (boardName != null)
              _OptionTile(
                icon: Icons.back_hand_outlined,
                label: 'Stop seeing Pins based on\n$boardName',
                onTap: () {
                  Navigator.pop(context);
                  onStopSeeingPins?.call();
                },
              ),
            _OptionTile(
              icon: Icons.block_outlined,
              label: 'Report Pin',
              subtitle: "This goes against Pinterest's\nCommunity Guidelines",
              onTap: () {
                Navigator.pop(context);
                onReport?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13, color: Colors.black),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
