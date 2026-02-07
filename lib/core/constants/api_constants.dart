class ApiConstants {
  ApiConstants._();

  // Pexels API
  static const String pexelsBaseUrl = 'https://api.pexels.com';
  static const String pexelsApiKey =
      'BmZzei5USYrFbzYWqKYdxtPLjywBd6FyMudnK1boRxRc1m1s4GpziyOo'; // Replace with your key

  // Endpoints
  static const String curatedPhotos = '/v1/curated';
  static const String searchPhotos = '/v1/search';
  static const String getPhoto = '/v1/photos';
  static const String popularVideos = '/videos/popular';
  static const String searchVideos = '/videos/search';

  // Unsplash API (Alternative)
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
  static const String unsplashAccessKey =
      'YOUR_UNSPLASH_ACCESS_KEY'; // Replace with your key

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 80;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Cache
  static const Duration cacheMaxAge = Duration(hours: 1);
  static const int maxCacheSize = 100;
}
