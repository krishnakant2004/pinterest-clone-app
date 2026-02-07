# Pinterest Clone - Flutter App

A pixel-perfect Pinterest clone built with Flutter, showcasing Clean Architecture, state management with Riverpod, and modern UI/UX patterns.

![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Features

### Core Features
- **Home Feed**: Pinterest-style masonry grid layout with infinite scroll
- **Search**: Real-time search with debouncing, trending suggestions, and category filters
- **Pin Details**: Full-screen pin view with hero animations and sharing capabilities
- **Boards**: Create, manage, and organize pins into boards
- **Profile**: User profile with created/saved tabs, boards grid, and settings

### Technical Highlights
- **Pixel-Perfect UI**: Faithful recreation of Pinterest's design system
-  **Clean Architecture**: Separation of concerns with Presentation, Domain, and Data layers
-  **State Management**: Riverpod with StateNotifier pattern
-  **Performance**: Optimized image loading with caching and shimmer placeholders
-  **Animations**: Smooth transitions, hero animations, and micro-interactions
-  **Dark Mode**: Full light/dark theme support
-  **Responsive**: Adaptive layouts for different screen sizes

## 🏛️ Architecture

```
lib/
├── main.dart
├── core/
│   ├── constants/       # API and app constants
│   ├── error/           # Failures and exceptions
│   ├── network/         # Dio client with retry logic
│   ├── router/          # GoRouter configuration
│   ├── theme/           # App theme and colors
│   ├── usecases/        # Base use case class
│   └── widgets/         # Shared widgets
├── features/
│   ├── auth/            # Authentication (Splash, Login, Signup)
│   ├── board/           # Board management
│   ├── home/            # Home feed
│   ├── pin/             # Pin creation, viewing, saving
│   ├── profile/         # User profile and settings
│   └── search/          # Search functionality
```

### Layer Responsibilities

| Layer | Purpose |
|-------|---------|
| **Presentation** | UI screens, widgets, and Riverpod providers |
| **Domain** | Business entities and repository interfaces |
| **Data** | API data sources, models, and repository implementations |

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation with deep linking |
| `dio` | HTTP client with interceptors |
| `cached_network_image` | Image caching |
| `shimmer` | Loading placeholders |
| `flutter_staggered_grid_view` | Masonry grid layout |
| `clerk_flutter` | Authentication (ready for integration) |
| `hive_flutter` | Local database |
| `share_plus` | Content sharing |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0 or higher
- A Pexels API key (free at [pexels.com/api](https://www.pexels.com/api/))

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pinterest_clone
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your Pexels API key**
   
   Open `lib/core/constants/api_constants.dart` and replace:
   ```dart
   static const String apiKey = 'YOUR_PEXELS_API_KEY';
   ```
   with your actual API key.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Key Files

| File | Description |
|------|-------------|
| `lib/main.dart` | App entry point with theme and router |
| `lib/core/router/app_router.dart` | Navigation configuration |
| `lib/core/theme/app_theme.dart` | Light/dark theme definitions |
| `lib/features/home/presentation/screens/home_screen.dart` | Main feed screen |
| `lib/features/pin/presentation/widgets/pin_card.dart` | Reusable pin card widget |
| `lib/features/search/presentation/screens/search_screen.dart` | Search functionality |

## 🎨 UI Components

### Pin Card
- Animated scale on tap
- Shimmer loading state
- Overlay with save button
- Hero animation support

### Masonry Grid
- Staggered layout like Pinterest
- Dynamic aspect ratios
- Infinite scroll pagination
- Pull-to-refresh

### Navigation
- Bottom navigation with 4 tabs
- Custom page transitions
- Deep linking support

## 🔧 Configuration

### API Configuration
Edit `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  static const String baseUrl = 'https://api.pexels.com/v1';
  static const String apiKey = 'YOUR_API_KEY';
  static const int perPage = 20;
}
```

### Theme Configuration
Edit `lib/core/theme/app_colors.dart` to customize the color palette.

