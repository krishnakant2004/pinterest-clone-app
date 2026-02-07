2. Click **New bucket** and create these buckets:

| Bucket Name | Public | Description |
|------------|--------|-------------|
| `avatars` | ✅ Yes | User profile pictures |
| `pins` | ✅ Yes | User-uploaded pin images |
| `boards` | ✅ Yes | Board cover images |

3. For each bucket, go to **Policies** and add:
   - Click **New Policy** → **For full customization**
   - Policy name: `Allow public access`
   - For ALL operations, add: `true`

---

### Step 6: Test the Connection

Run your Flutter app:

```bash
flutter run
```

The app should:
1. ✅ Initialize Supabase connection
2. ✅ Initialize Hive for local storage
3. ✅ Work offline if Supabase is unreachable

---

## 📁 Project Structure After Setup

```
lib/
├── core/
│   ├── data/
│   │   └── models/
│   │       ├── board_model.dart        # Board Hive model
│   │       ├── board_model.g.dart      # Generated adapter
│   │       ├── saved_pin_model.dart    # Saved pin model
│   │       ├── saved_pin_model.g.dart
│   │       ├── like_model.dart         # Like model
│   │       ├── like_model.g.dart
│   │       ├── user_profile_model.dart # Profile model
│   │       └── user_profile_model.g.dart
│   ├── providers/
│   │   ├── boards_provider.dart        # Board state management
│   │   ├── saved_pins_provider.dart    # Saved pins state
│   │   ├── likes_provider.dart         # Likes state
│   │   └── user_profile_provider.dart  # Profile state
│   ├── repositories/
│   │   ├── board_repository.dart       # Board CRUD + sync
│   │   ├── saved_pin_repository.dart   # Pin saving + sync
│   │   ├── like_repository.dart        # Likes + sync
│   │   └── user_profile_repository.dart
│   └── services/
│       ├── supabase_service.dart       # Cloud operations
│       └── local_storage_service.dart  # Hive operations
└── main.dart                           # App initialization
```

---

## 🔧 How It Works

### Data Flow

```
User Action → Provider → Repository → Cloud (Supabase)
                              ↓
                         Local Cache (Hive)
```

### Offline Support

1. **When Online**: Data syncs to Supabase, cached in Hive
2. **When Offline**: Reads from Hive, marks changes as `isSynced: false`
3. **When Back Online**: Syncs unsynced items to cloud

### Example: Creating a Board

```dart
// In your widget
final boardsNotifier = ref.read(boardsProvider.notifier);

await boardsNotifier.createBoard(
  name: 'Travel Ideas',
  description: 'Places I want to visit',
);
// Automatically saves to Supabase + caches locally!
```

### Example: Saving a Pin

```dart
final savedPinsNotifier = ref.read(savedPinsProvider.notifier);

await savedPinsNotifier.savePin(
  pinId: pin.id.toString(),
  boardId: selectedBoard.id,
  imageUrl: pin.src.large,
  thumbnailUrl: pin.src.medium,
  title: pin.alt ?? '',
  width: pin.width,
  height: pin.height,
  photographer: pin.photographer,
);
```

### Example: Liking a Pin

```dart
final likesNotifier = ref.read(likesProvider.notifier);

await likesNotifier.toggleLike(pinId: pin.id.toString());
```

---

## 🎯 Next Steps

1. **Integrate with UI**: Use providers in your screens
2. **Add Create Board Screen**: Let users create boards
3. **Add Save to Board Dialog**: Show when user clicks save
4. **Add Like Button**: Toggle likes on pins
5. **Add Profile Screen**: Show user's boards and saved pins

---

## 🐛 Troubleshooting

### "Failed to initialize Supabase"
- Check your URL and API key
- Make sure project is fully created (wait 2-3 min)

### "Connection failed" 
- Check internet connection
- App will work offline with local data

### "Permission denied" on storage
- Make sure buckets are set to public
- Check storage policies are set correctly

### Data not syncing
- Check `isSynced` field on local items
- Call `syncPendingChanges()` on repositories

---

## 📱 Environment Variables (Optional)

For production, use environment variables instead of hardcoding:

```dart
// Create .env file
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...

// Install flutter_dotenv package
// Load in main.dart before Supabase.initialize()
```

---

Happy coding! 🎉
