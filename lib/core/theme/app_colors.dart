import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color pinterestRed = Color(0xFFE60023);
  static const Color pinterestRedDark = Color(0xFFAD081B);
  static const Color pinterestRedLight = Color(0xFFFF5247);

  // Neutral Colors
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF767676);
  static const Color greyLight = Color(0xFFEFEFEF);
  static const Color greyDark = Color(0xFF545454);
  static const Color greyBackground = Color(0xFFF5F5F5);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Semantic Colors
  static const Color error = Color(0xFFE60023);
  static const Color success = Color(0xFF00A86B);
  static const Color warning = Color(0xFFFF8C00);
  static const Color info = Color(0xFF0076D3);

  // Board Colors (Pinterest board cover colors)
  static const List<Color> boardColors = [
    Color(0xFFE60023), // Red
    Color(0xFF0076D3), // Blue
    Color(0xFF00A86B), // Green
    Color(0xFFFF8C00), // Orange
    Color(0xFF9B59B6), // Purple
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE91E63), // Pink
    Color(0xFF3498DB), // Light Blue
    Color(0xFF2ECC71), // Light Green
    Color(0xFFF39C12), // Yellow
  ];

  // Gradient for shimmer effect
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFFEBEBEB), Color(0xFFF5F5F5), Color(0xFFEBEBEB)],
    stops: [0.1, 0.5, 0.9],
  );

  // Overlay colors
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayMedium = Color(0x4D000000);
  static const Color overlayDark = Color(0x80000000);
}
