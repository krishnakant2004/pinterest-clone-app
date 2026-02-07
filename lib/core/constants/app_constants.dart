class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Pinterest';
  static const String appVersion = '1.0.0';

  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridMainAxisSpacing = 8.0;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridPadding = 8.0;

  // Pin Card
  static const double pinBorderRadius = 16.0;
  static const double pinMinHeight = 150.0;
  static const double pinMaxHeight = 350.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Hero Tags
  static const String heroPinImage = 'pin_image_';
  static const String heroProfileImage = 'profile_image_';

  // Asset Paths
  static const String assetsPath = 'assets';
  static const String imagesPath = '$assetsPath/images';
  static const String iconsPath = '$assetsPath/icons';
  static const String animationsPath = '$assetsPath/animations';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String searchHistoryKey = 'search_history';
  static const String recentPinsKey = 'recent_pins';

  // Search
  static const int maxSearchHistory = 20;
  static const int searchDebounceMs = 500;

  // Pagination
  static const int initialPageSize = 20;
  static const int loadMoreThreshold = 5;

  // Image Quality
  static const int thumbnailQuality = 50;
  static const int mediumQuality = 80;
  static const int highQuality = 100;
}
