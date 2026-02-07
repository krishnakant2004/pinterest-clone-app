import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/pin.dart';
import 'pin_options_bottom_sheet.dart';

class PinCard extends StatefulWidget {
  final Pin pin;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final bool isFullWidth; // For board content - single column full width

  const PinCard({
    super.key,
    required this.pin,
    this.onTap,
    this.onSave,
    this.onMore,
    this.isFullWidth = false,
  });

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateHeight(BuildContext context) {
    final aspectRatio = widget.pin.aspectRatio;

    if (widget.isFullWidth) {
      // For full-width mode, use actual screen width minus padding
      final screenWidth = MediaQuery.of(context).size.width;
      final width = screenWidth - 32; // 16px padding on each side
      return width / aspectRatio;
    }

    // For grid mode, clamp the height between min and max
    final baseWidth = 180.0; // approximate card width
    final calculatedHeight = baseWidth / aspectRatio;
    return calculatedHeight.clamp(
      AppConstants.pinMinHeight,
      AppConstants.pinMaxHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _calculateHeight(context);
    final avgColor =
        widget.pin.avgColor != null
            ? Color(int.parse(widget.pin.avgColor!.replaceFirst('#', '0xFF')))
            : AppColors.greyLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTapDown: (_) {
            _controller.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _controller.reverse();
            // If overlay is showing, hide it on tap; otherwise navigate
            if (_showOverlay) {
              setState(() => _showOverlay = false);
            } else {
              widget.onTap?.call();
            }
          },
          onTapCancel: () {
            _controller.reverse();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            setState(() => _showOverlay = true);
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            // Image Container
            child: Hero(
              tag: '${AppConstants.heroPinImage}${widget.pin.id}',
              child: Container(
                height: height,
                width: widget.isFullWidth ? double.infinity : null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.pinBorderRadius,
                  ),
                  color: avgColor.withOpacity(0.3),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.pinBorderRadius,
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                            widget.pin.thumbnailUrl ?? widget.pin.imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Shimmer.fromColors(
                              baseColor: avgColor.withOpacity(0.3),
                              highlightColor: avgColor.withOpacity(0.1),
                              child: Container(
                                color: avgColor.withOpacity(0.3),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: avgColor.withOpacity(0.3),
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.grey,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          child: const Icon(Icons.more_horiz),
          onTap: () {
            PinOptionsBottomSheet.show(
              context: context,
              pin: widget.pin,
              onSave: widget.onSave,
            );
          },
        ),
      ],
    );
  }
}
