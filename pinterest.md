# Pinterest App Setup Guide

This guide will help you set up and understand the folder structure and workflow for the Pinterest Clone Flutter app.

---

## 📁 Folder Structure Overview

```
lib/
  main.dart                # App entry point
  core/
    router/                # App routing (GoRouter, route names)
    theme/                 # App-wide theme and colors
    widgets/               # Shared widgets (e.g., navigation, shimmer)
  features/
    auth/                  # Authentication (login, splash, providers)
    home/                  # Home screen and logic
    pin/                   # Pin creation, details, models
    search/                # Search UI and logic
    profile/               # User profile, settings
    board_screen/          # Boards (create, detail)
  assets/
    icons/                 # App icons
supabase/
  schema.sql               # Database schema for Supabase
android/, ios/, web/, ...  # Platform-specific code
README.md                  # Project overview
pinterest.md               # (This file)
pubspec.yaml               # Dependencies
```

---

## 🛠️ Setup & Workflow

### 1. Clone the Repository

```sh
git clone <your-repo-url>
cd pininterest
```

### 2. Install Dependencies

```sh
flutter pub get
```

### 3. Configure Supabase

- Go to [supabase.com](https://supabase.com) and create a new project.
- Copy your **Project URL** and **anon public key** from Supabase Dashboard (Settings → API).
- Open `lib/core/services/supabase_service.dart` and set:

```dart
static const String _supabaseUrl = 'https://your-project-id.supabase.co';
static const String _supabaseAnonKey = 'your-anon-key';
```

- To set up the database, open Supabase Dashboard → SQL Editor, copy contents of `supabase/schema.sql`, and run the query.

### 4. Run the App

```sh
flutter run
```

### 5. Folder/Feature Development

- Add new screens or features under `lib/features/<feature_name>/`.
- Shared widgets go in `lib/core/widgets/`.
- Update navigation in `lib/core/router/app_router.dart`.

---

## 🚦 Typical Workflow

1. **Start the app**: Splash screen appears immediately, then routes to login or home.
2. **Authentication**: Handled in `features/auth/presentation/screens/`.
3. **Main navigation**: Managed by GoRouter in `core/router/`.
4. **Feature screens**: Each feature (pins, boards, search, etc.) has its own folder.
5. **Supabase**: Used for backend (auth, storage, database). All schema changes go in `supabase/schema.sql`.

---

## 📝 Notes
- For any new backend tables, update `supabase/schema.sql` and re-run in Supabase SQL Editor.
- Use Riverpod for state management (see providers in each feature).
- For assets, add to `assets/` and update `pubspec.yaml` if needed.

---

For more details, see the `README.md` or ask the project maintainer.
