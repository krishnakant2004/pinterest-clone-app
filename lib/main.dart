import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

// Replace with your Clerk publishable key from dashboard.clerk.com
const clerkPublishableKey =
    'pk_test_a25vd24tdHVydGxlLTMyLmNsZXJrLmFjY291bnRzLmRldiQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive)
  await LocalStorageService.initialize();

  // Initialize Supabase for cloud storage
  // Note: Replace credentials in supabase_service.dart with your own
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // Supabase init may fail if credentials not set - app still works offline
    debugPrint('Supabase initialization skipped: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ClerkAuth(
      config: ClerkAuthConfig(publishableKey: clerkPublishableKey),
      child: const ProviderScope(child: PinterestCloneApp()),
    ),
  );
}

class PinterestCloneApp extends ConsumerWidget {
  const PinterestCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Pinterest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
