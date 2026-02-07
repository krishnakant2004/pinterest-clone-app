import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Circular icon button with background (used for back button, visual search, etc.)
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final double borderRadius;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 24,
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
      ),
    );
  }
}

/// Back button specifically styled for Pinterest
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppBackButton({super.key, this.onTap, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return CircularIconButton(
      icon: Icons.arrow_back_rounded,
      backgroundColor: Colors.white.withAlpha(100),
      iconColor: Colors.black,
      onTap: onTap ?? () => Navigator.of(context).pop(),
      borderRadius: 12,
    );
  }
}
