
## Supabase Configuration for Pinterest Clone Flutter App

Copy your **Project URL** and **anon public key**.
Open `lib/core/services/supabase_service.dart` in your Flutter project.

```dart
static const String _supabaseUrl = 'https://your-project-id.supabase.co';
static const String _supabaseAnonKey = 'your-anon-key';
```

```

### Example: Liking a Pin

```dart
final likesNotifier = ref.read(likesProvider.notifier);

await likesNotifier.toggleLike(pinId: pin.id.toString());
```

---

## Next Steps

1. **Integrate with UI**: Use providers in your screens
2. **Add Create Board Screen**: Let users create boards
3. **Add Save to Board Dialog**: Show when user clicks save
4. **Add Like Button**: Toggle likes on pins
5. **Add Profile Screen**: Show user's boards and saved pins

---

